import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/gradient_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(authStateProvider.notifier).register(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (mounted) context.go('/register-success');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text('Tạo tài khoản', style: AppTextStyles.displayMedium),
                      const SizedBox(height: 8),
                      Text('Bắt đầu hành trình âm nhạc của bạn', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 32),
                      _buildForm(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorBanner(_errorMessage!),
                      ],
                      const SizedBox(height: 32),
                      GradientButton(
                        text: 'Đăng ký',
                        onPressed: _submit,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),
                      _buildLoginLink(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
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
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Họ và tên',
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.user, color: AppColors.textMuted)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.envelope, color: AppColors.textMuted)),
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
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Mật khẩu',
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.lock, color: AppColors.textMuted)),
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscurePass ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirm,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Xác nhận mật khẩu',
              prefixIcon: Center(widthFactor: 1.0, child: FaIcon(FontAwesomeIcons.lock, color: AppColors.textMuted)),
              suffixIcon: IconButton(
                icon: FaIcon(
                  _obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (v != _passCtrl.text) return 'Mật khẩu không khớp';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Đã có tài khoản? ', style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Đăng nhập',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
