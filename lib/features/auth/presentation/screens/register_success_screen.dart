import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';

class RegisterSuccessScreen extends ConsumerStatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  ConsumerState<RegisterSuccessScreen> createState() =>
      _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends ConsumerState<RegisterSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<Offset> _exitSlide;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut));

    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _checkCtrl, curve: const Interval(0.0, 0.35, curve: Curves.easeIn)),
    );

    _ringScale = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(
          parent: _checkCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
          parent: _checkCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _goHome() async {
    await _exitCtrl.forward();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final firstName = _firstName(authState.userName ?? 'bạn');

    return SlideTransition(
      position: _exitSlide,
      child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 44),
                  _buildCheckCircle(),
                  const SizedBox(height: 40),
                  _FadeSlide(
                    delay: const Duration(milliseconds: 700),
                    child: Text(
                      'Chào mừng, $firstName!',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FadeSlide(
                    delay: const Duration(milliseconds: 900),
                    child: Text(
                      'Tài khoản của bạn đã được tạo thành công.\nBắt đầu khám phá âm nhạc dân tộc Việt Nam ngay thôi!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 3),
                  _FadeSlide(
                    delay: const Duration(milliseconds: 1300),
                    child: _buildButton(context),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
        Container(color: Colors.black.withValues(alpha: 0.55)),
      ],
    );
  }

  Widget _buildLogo() {
    return _FadeSlide(
      delay: const Duration(milliseconds: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset('assets/images/logo.png', width: 96, height: 96),
      ),
    );
  }

  Widget _buildCheckCircle() {
    return AnimatedBuilder(
      animation: _checkCtrl,
      builder: (_, _) {
        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple ring
              Opacity(
                opacity: _ringOpacity.value,
                child: Transform.scale(
                  scale: _ringScale.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.success, width: 2),
                    ),
                  ),
                ),
              ),
              // Check circle
              Opacity(
                opacity: _checkOpacity.value,
                child: Transform.scale(
                  scale: _checkScale.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withValues(alpha: 0.15),
                      border: Border.all(
                          color: AppColors.success, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _goHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bắt đầu học ngay',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.last;
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

class _FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeSlide({required this.child, required this.delay});

  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

