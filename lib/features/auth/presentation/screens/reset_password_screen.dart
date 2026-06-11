import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/gradient_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _done = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(widget.token, _passwordCtrl.text);
      if (mounted) setState(() => _done = true);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!_done)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _done ? _buildSuccess() : _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: FaIcon(FontAwesomeIcons.key, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 24),
        Text('Đặt lại mật khẩu', style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Nhập mật khẩu mới cho tài khoản của bạn.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu mới',
                  prefixIcon: Center(
                    widthFactor: 1.0,
                    child: FaIcon(FontAwesomeIcons.lock, color: AppColors.textMuted, size: 20),
                  ),
                  suffixIcon: IconButton(
                    icon: FaIcon(
                      _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Xác nhận mật khẩu',
                  prefixIcon: Center(
                    widthFactor: 1.0,
                    child: FaIcon(FontAwesomeIcons.lock, color: AppColors.textMuted, size: 20),
                  ),
                  suffixIcon: IconButton(
                    icon: FaIcon(
                      _obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Đặt lại mật khẩu',
          onPressed: _submit,
          isLoading: _isLoading,
          icon: FontAwesomeIcons.floppyDisk,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: FaIcon(FontAwesomeIcons.circleCheck, color: AppColors.success, size: 44),
        ),
        const SizedBox(height: 24),
        Text('Đặt lại thành công!', style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Mật khẩu của bạn đã được cập nhật. Hãy đăng nhập lại.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        GradientButton(
          text: 'Đăng nhập',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
