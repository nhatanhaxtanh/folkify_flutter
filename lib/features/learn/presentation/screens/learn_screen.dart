import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/instruments_data.dart';
import '../../domain/models/instrument.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == kInstruments.length) return _buildPromoCard();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _InstrumentCard(instrument: kInstruments[index]),
                  );
                },
                childCount: kInstruments.length + 1,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 84)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Học',
                style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Khám phá nhạc cụ dân tộc Việt Nam', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight)),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Folkify — Học nhạc dân tộc',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Lộ trình học từ Beginner → Advanced, kết hợp video bài giảng và sheet nhạc tương ứng.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
          ),
        ],
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final Instrument instrument;
  const _InstrumentCard({required this.instrument});

  @override
  Widget build(BuildContext context) {
    final beginnerCount = instrument.lessons.where((l) => l.level == 'Beginner').length;
    final intermediateCount = instrument.lessons.where((l) => l.level == 'Intermediate').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(context),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (beginnerCount > 0) _levelBadge('$beginnerCount Beginner', const Color(0xFF16A34A)),
                    if (beginnerCount > 0 && intermediateCount > 0) const SizedBox(width: 6),
                    if (intermediateCount > 0) _levelBadge('$intermediateCount Intermediate', const Color(0xFFD97706)),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < instrument.difficulty ? Iconsax.star5 : Iconsax.star,
                        size: 14,
                        color: i < instrument.difficulty ? const Color(0xFFF59E0B) : AppColors.border,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...instrument.lessons.map((lesson) => _LessonRow(lesson: lesson, instrument: instrument)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/learn/${instrument.id}'),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          height: 110,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                instrument.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(color: AppColors.primaryDark),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0.65)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.music5, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          instrument.name,
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '0%',
                              style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            Text('hoàn thành', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _bannerBadge(instrument.category),
                        const SizedBox(width: 6),
                        Text(
                          '${instrument.lessons.length} video',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _levelBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final Lesson lesson;
  final Instrument instrument;
  const _LessonRow({required this.lesson, required this.instrument});

  @override
  Widget build(BuildContext context) {
    final isBeginnerLevel = lesson.level == 'Beginner';
    final levelColor = isBeginnerLevel ? const Color(0xFF16A34A) : const Color(0xFFD97706);

    return GestureDetector(
      onTap: () => context.go('/learn/${instrument.id}/lesson/${lesson.id}'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chưa\nxem\nđược',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 9, height: 1.4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: AppTextStyles.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(lesson.level, style: AppTextStyles.bodySmall.copyWith(color: levelColor, fontSize: 10)),
                      ),
                      const SizedBox(width: 6),
                      Text(lesson.duration, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Clip đang hoàn thiện',
                    style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFD97706), fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '+${lesson.xp} XP',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
