import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/biometric_service.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;
  BiometricInfo _biometricInfo = (label: 'Sinh trắc học', icon: Icons.fingerprint_rounded);

  @override
  void initState() {
    super.initState();
    BiometricService.getBiometricInfo().then((info) {
      if (mounted) setState(() => _biometricInfo = info);
    });
    Future.delayed(const Duration(milliseconds: 400), _authenticate);
  }

  Future<void> _authenticate() async {
    if (!mounted || _isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    await ref.read(authStateProvider.notifier).authenticateWithBiometric();
    if (mounted) setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(authStateProvider).userName;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.55)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/images/logo.png', width: 80, height: 80),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Chào mừng trở lại!',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (userName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const Spacer(flex: 4),
                  _buildFaceIdButton(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      await ref.read(authStateProvider.notifier).skipBiometric();
                    },
                    child: Text(
                      'Tiếp tục không dùng ${_biometricInfo.label}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceIdButton() {
    return GestureDetector(
      onTap: _isAuthenticating ? null : _authenticate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isAuthenticating
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAuthenticating)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(_biometricInfo.icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text(
              _isAuthenticating ? 'Đang xác thực...' : 'Đăng nhập bằng ${_biometricInfo.label}',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
