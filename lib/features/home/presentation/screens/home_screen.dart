import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/instrument_provider.dart';
import '../../../learn/domain/models/instrument.dart';
import '../../../../core/providers/progress_provider.dart';
import '../../../../core/services/progress_service.dart';

const _kLocalImages = <String, String>{
  'dan-tranh': 'assets/images/instruments/dan_tranh.jpg',
};

const _kFeaturedImages = <String, String>{
  'dan-tranh': 'assets/images/instruments/dan_tranh_featured.jpg',
};

Widget _instrumentImage(InstrumentSummary inst,
    {BoxFit fit = BoxFit.cover, bool featured = false}) {
  final map = featured ? _kFeaturedImages : _kLocalImages;
  final local = map[inst.id] ?? _kLocalImages[inst.id];
  if (local != null) {
    return Image.asset(local, fit: fit);
  }
  return Image.network(
    inst.imageUrl,
    fit: fit,
    errorBuilder: (ctx, err, stack) =>
        Center(child: Text(inst.emoji, style: const TextStyle(fontSize: 60))),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final name = auth.userName ?? 'bạn';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, name, ref)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildDailyChallenge(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Tiếp tục học', onTap: () => context.go('/learn')),
                const SizedBox(height: 12),
                _buildContinueLearning(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Nhạc cụ nổi bật'),
                const SizedBox(height: 12),
                _buildFeaturedBanner(context, ref),
                const SizedBox(height: 24),
                _buildSectionTitle('Khám phá nhạc cụ', onTap: () => context.go('/learn')),
                const SizedBox(height: 12),
                _buildInstrumentsGrid(context, ref),
                const SizedBox(height: 24),
                _buildSectionTitle('Thành tích'),
                const SizedBox(height: 12),
                _buildAchievements(ref),
                const SizedBox(height: 16),
                _buildSheetMusicBanner(context),
                const SizedBox(height: 16),
                _buildStudyTimeCard(ref),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        image: DecorationImage(
          image: AssetImage('assets/images/header_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Folkify',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showNotifications(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FaIcon(FontAwesomeIcons.bell, color: Colors.white, size: 19),
                    ),
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        width: 19,
                        height: 19,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Chào mừng trở lại', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          const SizedBox(height: 2),
          Text(
            name,
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('Học viên · Cấp độ 3', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (ctx) {
                  final p = ref.watch(userProgressProvider).valueOrNull;
                  final done = p?.totalLessonsCompleted ?? 0;
                  final total = p?.totalLessons ?? 0;
                  final pct = total > 0 ? done / total : 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Tiến độ học tập', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                          const Spacer(),
                          _statBadge(FontAwesomeIcons.fire, '${p?.currentStreak ?? 0}', 'streak', const Color(0xFFF97316)),
                          const SizedBox(width: 12),
                          _statBadge(FontAwesomeIcons.bolt, '${p?.totalXp ?? 0}', 'XP', const Color(0xFFF59E0B)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$done${total > 0 ? '/$total' : ''} bài',
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      _AnimatedProgressBar(value: pct),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final notifications = [
      _NotifItem(
        icon: FontAwesomeIcons.book,
        iconColor: AppColors.primary,
        title: 'Bài học mới đã được thêm',
        body: 'Đàn Tranh nâng cao — Chương 3 vừa ra mắt',
        time: '5 phút trước',
        unread: true,
      ),
      _NotifItem(
        icon: FontAwesomeIcons.fire,
        iconColor: const Color(0xFFF97316),
        title: 'Streak 7 ngày!',
        body: 'Tuyệt vời! Bạn đang giữ vững phong độ luyện tập',
        time: '2 giờ trước',
        unread: true,
      ),
      _NotifItem(
        icon: FontAwesomeIcons.clock,
        iconColor: const Color(0xFF6366F1),
        title: 'Nhắc nhở học nhạc',
        body: 'Đã đến giờ luyện tập hàng ngày của bạn',
        time: '5 giờ trước',
        unread: true,
      ),
      _NotifItem(
        icon: FontAwesomeIcons.trophy,
        iconColor: const Color(0xFFF59E0B),
        title: 'Hoàn thành bài học',
        body: 'Bạn đã hoàn thành Sáo Trúc cơ bản — Chương 1',
        time: 'Hôm qua',
        unread: false,
      ),
      _NotifItem(
        icon: FontAwesomeIcons.crown,
        iconColor: const Color(0xFF1565C0),
        title: 'Ưu đãi Premium',
        body: 'Nâng cấp hôm nay để nhận 30 ngày dùng thử miễn phí',
        time: '2 ngày trước',
        unread: false,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Thông báo', style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Đánh dấu tất cả đã đọc',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (context, i) => const Divider(
                    height: 1,
                    indent: 68,
                    endIndent: 20,
                  ),
                  itemBuilder: (_, i) {
                    final n = notifications[i];
                    return Container(
                      color: n.unread
                          ? AppColors.primary.withValues(alpha: 0.04)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: n.iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: FaIcon(n.icon, color: n.iconColor, size: 17),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: AppTextStyles.labelMedium.copyWith(
                                          fontWeight: n.unread ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (n.unread)
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF97316),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(n.body, style: AppTextStyles.bodySmall),
                                const SizedBox(height: 4),
                                Text(
                                  n.time,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBadge(FaIconData icon, String value, String label, Color color) {
    return Row(
      children: [
        FaIcon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
        const SizedBox(width: 2),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: FaIcon(FontAwesomeIcons.medal, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thử thách hôm nay', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                const SizedBox(height: 2),
                Text(
                  'Luyện 15 phút Sáo Trúc',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => context.go('/practice'),
            icon: FaIcon(FontAwesomeIcons.play, size: 14),
            label: const Text('Bắt đầu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: AppTextStyles.labelMedium.copyWith(fontSize: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 12)),
                  const SizedBox(width: 5),
                  FaIcon(FontAwesomeIcons.arrowRight, size: 11, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueLearning(BuildContext context) {
    final lessons = [
      {'title': 'Bài Lý Con Sáo', 'sub': 'Đàn Tranh', 'progress': 0.35, 'color': const Color(0xFFF59E0B)},
      {'title': 'Bài Trống Cơm', 'sub': 'Sáo Trúc', 'progress': 0.60, 'color': AppColors.primaryLight},
    ];

    return Column(
      children: lessons.map((l) {
        final progress = l['progress'] as double;
        final color = l['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: FaIcon(FontAwesomeIcons.play, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l['title'] as String, style: AppTextStyles.titleMedium),
                    Text(l['sub'] as String, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, WidgetRef ref) {
    final inst = ref.watch(instrumentListProvider).valueOrNull?.firstOrNull;
    if (inst == null) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));

    return GestureDetector(
      onTap: () => context.go('/learn/${inst.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _instrumentImage(inst, fit: BoxFit.cover, featured: true),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(inst.category, style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(height: 6),
                    Text(inst.name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    Text('${inst.lessonCount} bài học', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              Positioned(
                right: 12, bottom: 12,
                child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.arrowRight, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentsGrid(BuildContext context, WidgetRef ref) {
    final instruments = ref.watch(instrumentListProvider).valueOrNull ?? const [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: instruments.length,
      itemBuilder: (context, index) {
        final inst = instruments[index];
        return GestureDetector(
          onTap: () => context.go('/learn/${inst.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: _instrumentImage(inst, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Text(
                    inst.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievements(WidgetRef ref) {
    final data = ref.watch(achievementsProvider).valueOrNull;
    final items = data?.unlocked.take(3).toList() ?? const <Achievement>[];

    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final badge = entry.value;
        final color = _badgeColor(badge.icon);
        return Expanded(
          child: Container(
            margin: i < items.length - 1 ? const EdgeInsets.only(right: 10) : EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                FaIcon(_badgeIcon(badge.icon), color: color, size: 26),
                const SizedBox(height: 6),
                Text(badge.name, textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11), maxLines: 2),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  FaIconData _badgeIcon(String icon) => switch (icon) {
    'bullseye' => FontAwesomeIcons.bullseye,
    'star' => FontAwesomeIcons.star,
    'trophy' => FontAwesomeIcons.trophy,
    'fire' => FontAwesomeIcons.fire,
    'crown' => FontAwesomeIcons.crown,
    'music' => FontAwesomeIcons.music,
    _ => FontAwesomeIcons.medal,
  };

  Color _badgeColor(String icon) => switch (icon) {
    'fire' => const Color(0xFFF97316),
    'star' || 'crown' => const Color(0xFFF59E0B),
    'trophy' => const Color(0xFFDC2626),
    _ => AppColors.primary,
  };

  Widget _buildSheetMusicBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/sheets'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: FaIcon(FontAwesomeIcons.fileLines, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thư viện sheet nhạc', style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
                  const SizedBox(height: 2),
                  Text(
                    'Khám phá 8+ bản nhạc dân tộc',
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            FaIcon(FontAwesomeIcons.arrowRight, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: FaIcon(FontAwesomeIcons.clock, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thời gian học hôm nay', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Builder(builder: (ctx) {
                    final p = ref.watch(weeklyActivityProvider).valueOrNull;
                    final todayMinutes = p?.where((d) => d.isToday).firstOrNull?.minutes ?? 0;
                    return Text('$todayMinutes phút', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700));
                  }),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Mục tiêu', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                '60 phút',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool unread;
  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });
}

class _AnimatedProgressBar extends StatefulWidget {
  final double value;
  const _AnimatedProgressBar({required this.value});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween(begin: 0.0, end: widget.value)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final from = _anim.value;
      _anim = Tween(begin: from, end: widget.value)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _anim.value,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(_anim.value * 100).toInt()}% hoàn thành',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
