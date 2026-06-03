import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../learn/data/instruments_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final name = auth.userName ?? 'bạn';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, name)),
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
                _buildFeaturedBanner(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Khám phá nhạc cụ', onTap: () => context.go('/learn')),
                const SizedBox(height: 12),
                _buildInstrumentsGrid(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Thành tích'),
                const SizedBox(height: 12),
                _buildAchievements(),
                const SizedBox(height: 16),
                _buildSheetMusicBanner(context),
                const SizedBox(height: 16),
                _buildStudyTimeCard(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Iconsax.music5, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Folkify',
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Iconsax.notification, color: Colors.white, size: 20),
                  ),
                  Positioned(
                    right: 9,
                    top: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ],
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
                Row(
                  children: [
                    Text('Tiến độ học tập', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    const Spacer(),
                    _statBadge('🔥', '7', 'streak'),
                    const SizedBox(width: 12),
                    _statBadge('⚡', '230', 'XP'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '7/18 bài',
                  style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 7 / 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text('39% hoàn thành', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String emoji, String value, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 2),
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
            child: Icon(Iconsax.medal_star, color: Colors.white, size: 22),
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
            icon: Icon(Iconsax.play5, size: 14),
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
            child: Row(
              children: [
                Text('Xem tất cả', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 13)),
                Icon(Iconsax.arrow_right_3, size: 14, color: AppColors.primary),
              ],
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
                child: Icon(Iconsax.play5, color: Colors.white, size: 22),
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

  Widget _buildFeaturedBanner(BuildContext context) {
    final inst = kInstruments.first;
    return GestureDetector(
      onTap: () => context.go('/learn/${inst.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                inst.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _e) => Container(color: AppColors.primary),
              ),
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
                      child: Text(
                        inst.category,
                        style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      inst.name,
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text('${inst.lessons.length} bài học', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Iconsax.arrow_right_3, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: kInstruments.length,
      itemBuilder: (context, index) {
        final inst = kInstruments[index];
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
                      child: Image.network(
                        inst.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) =>
                            Center(child: Text(inst.emoji, style: const TextStyle(fontSize: 36))),
                      ),
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

  Widget _buildAchievements() {
    final items = [
      {'icon': '🔥', 'label': '7 ngày liên tiếp'},
      {'icon': '⭐', 'label': 'Nhạc cụ đầu tiên'},
      {'icon': '🏆', 'label': 'Hoàn thành 5 bài'},
    ];
    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
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
                Text(item['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  item['label']!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

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
              child: Icon(Iconsax.document_text5, color: Colors.white, size: 22),
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
            Icon(Iconsax.arrow_right_3, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyTimeCard() {
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
            child: Icon(Iconsax.clock, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thời gian học hôm nay', style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text('45 phút', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
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
