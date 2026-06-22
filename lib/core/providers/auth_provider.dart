import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/token_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final bool requiresBiometric;
  final String? userName;
  final String? userEmail;
  final String? userId;
  final String? role;

  const AuthState({
    required this.isLoggedIn,
    this.requiresBiometric = false,
    this.userName,
    this.userEmail,
    this.userId,
    this.role,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? requiresBiometric,
    String? userName,
    String? userEmail,
    String? userId,
    String? role,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      requiresBiometric: requiresBiometric ?? this.requiresBiometric,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const _keyUserName = 'folkify_user_name';
  static const _keyUserEmail = 'folkify_user_email';
  static const _keyUserId = 'folkify_user_id';
  static const _keyUserRole = 'folkify_user_role';
  static const _keyBiometricEnabled = 'folkify_biometric_enabled';

  @override
  AuthState build() {
    ApiClient.onSessionExpired = clearSession;
    _loadFromStorage();
    return const AuthState(isLoggedIn: false);
  }

  Future<void> _loadFromStorage() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) return;

    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;

    if (biometricEnabled && await BiometricService.isAvailable()) {
      state = const AuthState(isLoggedIn: false, requiresBiometric: true);
      return;
    }

    state = _buildLoggedInState(prefs);
  }

  AuthState _buildLoggedInState(SharedPreferences prefs) => AuthState(
        isLoggedIn: true,
        userName: prefs.getString(_keyUserName),
        userEmail: prefs.getString(_keyUserEmail),
        userId: prefs.getString(_keyUserId),
        role: prefs.getString(_keyUserRole),
      );

  Future<bool> authenticateWithBiometric() async {
    final success = await BiometricService.authenticate();
    if (!success) return false;
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        final tokens = await AuthService.refreshAccessToken(refreshToken);
        await _persistUser(tokens);
        state = AuthState(
          isLoggedIn: true,
          userEmail: tokens.user.email,
          userName: tokens.user.name,
          userId: tokens.user.id,
          role: tokens.user.role,
        );
        return true;
      }
    } catch (_) {
      // Không có mạng hoặc refresh thất bại — dùng credentials đã lưu
    }
    final prefs = await SharedPreferences.getInstance();
    state = _buildLoggedInState(prefs);
    return true;
  }

  Future<void> skipBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    state = _buildLoggedInState(prefs);
  }

  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, true);
  }

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, false);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<void> _persistUser(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      TokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      ),
      prefs.setString(_keyUserName, tokens.user.name),
      prefs.setString(_keyUserEmail, tokens.user.email),
      prefs.setString(_keyUserId, tokens.user.id),
      prefs.setString(_keyUserRole, tokens.user.role),
    ]);
  }

  Future<void> login(String email, String password) async {
    final tokens = await AuthService.login(email, password);
    await _persistUser(tokens);
    state = AuthState(
      isLoggedIn: true,
      userEmail: tokens.user.email,
      userName: tokens.user.name,
      userId: tokens.user.id,
      role: tokens.user.role,
    );
  }

  Future<void> register(String name, String email, String password) async {
    final tokens = await AuthService.register(name, email, password);
    await _persistUser(tokens);
    state = AuthState(
      isLoggedIn: true,
      userEmail: tokens.user.email,
      userName: tokens.user.name,
      userId: tokens.user.id,
      role: tokens.user.role,
    );
  }

  Future<bool> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: '293181909519-ca83elb1tee2g9ndilv669jt9k7vr1vp.apps.googleusercontent.com',
    );
    final account = await googleSignIn.signIn();
    if (account == null) return false;

    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw AuthException('Không lấy được Google token');

    final tokens = await AuthService.loginWithGoogle(idToken);
    await _persistUser(tokens);
    state = AuthState(
      isLoggedIn: true,
      userEmail: tokens.user.email,
      userName: tokens.user.name,
      userId: tokens.user.id,
      role: tokens.user.role,
    );
    return true;
  }

  Future<bool> loginWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) throw AuthException('Không lấy được Apple token');

    final givenName = credential.givenName;
    final familyName = credential.familyName;
    final fullName = [givenName, familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    final tokens = await AuthService.loginWithApple(
      identityToken,
      fullName: fullName.isEmpty ? null : fullName,
    );
    await _persistUser(tokens);
    state = AuthState(
      isLoggedIn: true,
      userEmail: tokens.user.email,
      userName: tokens.user.name,
      userId: tokens.user.id,
      role: tokens.user.role,
    );
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;

    if (biometricEnabled) {
      // Giữ refresh token để dùng biometric re-login
      await TokenStorage.clearAccessToken();
    } else {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await AuthService.logout(refreshToken);
      }
      await TokenStorage.clearTokens();
    }

    await Future.wait([
      prefs.remove(_keyUserName),
      prefs.remove(_keyUserEmail),
      prefs.remove(_keyUserId),
      prefs.remove(_keyUserRole),
    ]);
    state = const AuthState(isLoggedIn: false);
  }

  Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    state = state.copyWith(userName: name);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await TokenStorage.clearTokens();
    await Future.wait([
      prefs.remove(_keyUserName),
      prefs.remove(_keyUserEmail),
      prefs.remove(_keyUserId),
      prefs.remove(_keyUserRole),
    ]);
    state = const AuthState(isLoggedIn: false);
  }

  Future<bool> biometricRelogin() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;
    final success = await BiometricService.authenticate();
    if (!success) return false;
    try {
      final tokens = await AuthService.refreshAccessToken(refreshToken);
      await _persistUser(tokens);
      state = AuthState(
        isLoggedIn: true,
        userEmail: tokens.user.email,
        userName: tokens.user.name,
        userId: tokens.user.id,
        role: tokens.user.role,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
