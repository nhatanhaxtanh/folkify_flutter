import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userName;
  final String? userEmail;

  const AuthState({
    required this.isLoggedIn,
    this.userName,
    this.userEmail,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userName,
    String? userEmail,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const _keyLoggedIn = 'folkify_logged_in';
  static const _keyUserName = 'folkify_user_name';
  static const _keyUserEmail = 'folkify_user_email';

  @override
  AuthState build() {
    _loadFromStorage();
    return const AuthState(isLoggedIn: false);
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (isLoggedIn) {
      state = AuthState(
        isLoggedIn: true,
        userName: prefs.getString(_keyUserName),
        userEmail: prefs.getString(_keyUserEmail),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, email.split('@').first);
    state = AuthState(
      isLoggedIn: true,
      userEmail: email,
      userName: email.split('@').first,
    );
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    state = AuthState(isLoggedIn: true, userEmail: email, userName: name);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    state = const AuthState(isLoggedIn: false);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
