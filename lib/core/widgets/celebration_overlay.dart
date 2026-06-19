import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/progress_service.dart';

class CelebrationOverlay extends StatefulWidget {
  final bool _isAchievement;
  final Achievement? achievement;
  final int? streakDays;

  const CelebrationOverlay._({
    required bool isAchievement,
    this.achievement,
    this.streakDays,
  }) : _isAchievement = isAchievement; // ignore: prefer_initializing_formals

  factory CelebrationOverlay.achievement(Achievement achievement) =>
      CelebrationOverlay._(isAchievement: true, achievement: achievement);

  factory CelebrationOverlay.streak(int days) =>
      CelebrationOverlay._(isAchievement: false, streakDays: days);

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _pulse;

  late final Animation<double> _backdropFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconPulse;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _buttonFade;

  late final List<_Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _backdropFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _cardScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.05, 0.58, curve: Curves.elasticOut),
    );

    _cardFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.05, 0.28, curve: Curves.easeOut),
    );

    _iconScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.28, 0.72, curve: Curves.elasticOut),
    );

    _iconPulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _contentFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.5, 0.82, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.5, 0.82, curve: Curves.easeOut),
    ));

    _buttonFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
    );

    final rng = Random(DateTime.now().millisecondsSinceEpoch);
    final colors = widget._isAchievement
        ? const [
            Color(0xFFFBBF24),
            Color(0xFFF59E0B),
            Color(0xFFFDE68A),
            Colors.white,
            Color(0xFF86EFAC),
            Color(0xFFA3E635),
          ]
        : const [
            Color(0xFFF97316),
            Color(0xFFFBBF24),
            Color(0xFFFED7AA),
            Colors.white,
            Color(0xFFFCA5A5),
            Color(0xFFF59E0B),
          ];

    _sparkles = List.generate(50, (_) => _Sparkle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 2.5 + rng.nextDouble() * 7.5,
      phase: rng.nextDouble(),
      speed: 0.35 + rng.nextDouble() * 0.65,
      color: colors[rng.nextInt(colors.length)],
    ));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _sparkleCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Color get _accent => widget._isAchievement
      ? _achievementColor(widget.achievement?.icon ?? '')
      : const Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _backdropFade,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.84)),
            ),
          ),
          AnimatedBuilder(
            animation: _sparkleCtrl,
            builder: (ctx2, anim) => CustomPaint(
              size: screenSize,
              painter: _SparklePainter(_sparkleCtrl.value, _sparkles),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_cardScale, _cardFade]),
              builder: (_, child) => Transform.scale(
                scale: _cardScale.value,
                child: FadeTransition(opacity: _cardFade, child: child),
              ),
              child: _buildCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _accent.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.32),
            blurRadius: 56,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_iconScale, _iconPulse]),
            builder: (_, child) => Transform.scale(
              scale: _iconScale.value * _iconPulse.value,
              child: child,
            ),
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.13),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.45),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(_icon, color: _accent, size: 54),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _title,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          FadeTransition(
            opacity: _buttonFade,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  widget._isAchievement ? 'Tuyệt vời! 🎉' : 'Tiếp tục cháy! 🔥',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FaIconData get _icon {
    if (!widget._isAchievement) return FontAwesomeIcons.fire;
    return switch (widget.achievement?.icon ?? '') {
      'bullseye' => FontAwesomeIcons.bullseye,
      'star' => FontAwesomeIcons.star,
      'trophy' => FontAwesomeIcons.trophy,
      'fire' => FontAwesomeIcons.fire,
      'crown' => FontAwesomeIcons.crown,
      'music' => FontAwesomeIcons.music,
      _ => FontAwesomeIcons.medal,
    };
  }

  String get _label =>
      widget._isAchievement ? '🏅  THÀNH TÍCH MỚI' : '🔥  STREAK MỚI';

  String get _title {
    if (!widget._isAchievement) return '${widget.streakDays} ngày liên tiếp!';
    return widget.achievement?.name ?? '';
  }

  String get _subtitle {
    if (!widget._isAchievement) {
      return switch (widget.streakDays) {
        3 => 'Khởi đầu tốt! Tiếp tục duy trì nhé.',
        7 => 'Một tuần kiên trì! Bạn đang trên đà tốt.',
        14 => 'Hai tuần không nghỉ! Thật ấn tượng.',
        30 => 'Một tháng xuất sắc! Bạn thật tuyệt vời.',
        60 => 'Hai tháng siêu cấp! Không ai ngăn được bạn!',
        100 => '100 ngày huyền thoại! Bạn là huyền thoại!',
        _ => 'Bạn đã học ${widget.streakDays} ngày liên tiếp. Tuyệt vời!',
      };
    }
    return widget.achievement?.description ?? '';
  }

  Color _achievementColor(String icon) => switch (icon) {
    'fire' => const Color(0xFFF97316),
    'star' || 'crown' => const Color(0xFFF59E0B),
    'trophy' => const Color(0xFFDC2626),
    _ => AppColors.primary,
  };
}

class _Sparkle {
  final double x, y, size, phase, speed;
  final Color color;

  const _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.speed,
    required this.color,
  });
}

class _SparklePainter extends CustomPainter {
  final double t;
  final List<_Sparkle> sparkles;

  const _SparklePainter(this.t, this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final phase = ((t * s.speed + s.phase) % 1.0);
      final opacity =
          (phase < 0.5 ? phase * 2 : (1.0 - phase) * 2).clamp(0.0, 1.0);
      if (opacity < 0.07) continue;

      final cx = s.x * size.width;
      final cy = s.y * size.height;
      final r = s.size * (0.35 + opacity * 0.65);

      final paint = Paint()
        ..color = s.color.withValues(alpha: opacity * 0.92)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.4;

      canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
      canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);

      final d = r * 0.6;
      final diagPaint = Paint()
        ..color = s.color.withValues(alpha: opacity * 0.52)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.24;
      canvas.drawLine(
          Offset(cx - d, cy - d), Offset(cx + d, cy + d), diagPaint);
      canvas.drawLine(
          Offset(cx + d, cy - d), Offset(cx - d, cy + d), diagPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}
