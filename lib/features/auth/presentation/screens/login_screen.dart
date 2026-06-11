import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/token_storage.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isBiometricLoading = false;
  bool _biometricReady = false;
  BiometricInfo _biometricInfo = (label: 'Face ID', icon: Icons.face_retouching_natural_rounded);
  String? _errorMessage;

  late final AnimationController _exitCtrl;
  late final Animation<Offset> _exitSlide;

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));
    _checkBiometricOption();
  }

  Future<void> _checkBiometricOption() async {
    final enabled = await ref.read(authStateProvider.notifier).isBiometricEnabled();
    if (!enabled) return;
    final available = await BiometricService.isAvailable();
    if (!available) return;
    final token = await TokenStorage.getRefreshToken();
    if (token == null) return;
    final info = await BiometricService.getBiometricInfo();
    if (mounted) setState(() { _biometricReady = true; _biometricInfo = info; });
  }

  Future<void> _loginWithBiometric() async {
    setState(() => _isBiometricLoading = true);
    try {
      final success = await ref.read(authStateProvider.notifier).biometricRelogin();
      if (!success && mounted) {
        setState(() => _errorMessage = 'Xác thực thất bại, vui lòng đăng nhập bằng mật khẩu');
      }
    } finally {
      if (mounted) setState(() => _isBiometricLoading = false);
    }
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(authStateProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (mounted) {
        await _exitCtrl.forward();
        if (mounted) context.go('/');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _exitSlide,
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_bg.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildBadges(),
                    const SizedBox(height: 28),
                    _buildForm(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _buildErrorBanner(_errorMessage!),
                    ],
                    const SizedBox(height: 12),
                    _buildForgotPassword(),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildGoogleButton(),
                    if (_biometricReady) ...[
                      const SizedBox(height: 12),
                      _buildFaceIdButton(),
                    ],
                    const SizedBox(height: 20),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/logo.png',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Đăng nhập',
          style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'Đăng nhập để bắt đầu học nhạc cụ cùng Folkify',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Badge('Dân tộc Việt'),
        const SizedBox(width: 8),
        _Badge('Học theo bài'),
      ],
    );
  }

  Widget _buildForm() {
    const fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.white24),
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.white, width: 1.5),
    );
    const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.error),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) { if (_errorMessage != null) setState(() => _errorMessage = null); },
            decoration: InputDecoration(
              hintText: 'you@example.com',
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.envelope, color: Colors.white.withValues(alpha: 0.6), size: 20)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập email';
              final valid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!valid.hasMatch(v.trim())) return 'Email không đúng định dạng (vd: ten@gmail.com)';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu',
              labelText: 'Mật khẩu',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.lock, color: Colors.white.withValues(alpha: 0.6), size: 20)),
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscurePass ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: errorBorder,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.push('/forgot-password'),
        child: Text(
          'Quên mật khẩu?',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Đăng nhập',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isGoogleLoading ? null : () async {
          setState(() => _isGoogleLoading = true);
          try {
            final success = await ref.read(authStateProvider.notifier).loginWithGoogle();
            if (success && mounted) context.go('/');
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng nhập Google thất bại: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _isGoogleLoading = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3C4043),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3C4043)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/google_logo.svg', width: 20, height: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Đăng nhập với Google',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: const Color(0xFF3C4043),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFaceIdButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isBiometricLoading ? null : _loginWithBiometric,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isBiometricLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_biometricInfo.icon, size: 22, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Đăng nhập bằng ${_biometricInfo.label}',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: Text(
            'Đăng ký',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
