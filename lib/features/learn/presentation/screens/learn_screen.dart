import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/instrument_provider.dart';
import '../../domain/models/instrument.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instrumentsAsync = ref.watch(instrumentListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          instrumentsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.triangleExclamation,
                        color: AppColors.textMuted, size: 36),
                    const SizedBox(height: 12),
                    Text(err.toString(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(instrumentListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
            data: (instruments) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == instruments.length) {
                      return _buildPromoCard();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _InstrumentCard(instrument: instruments[index]),
                    );
                  },
                  childCount: instruments.length + 1,
                ),
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
        image: DecorationImage(
          image: AssetImage('assets/images/header_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png',
                    width: 36, height: 36, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Text('Folkify',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.book, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text('Học',
                  style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Khám phá nhạc cụ dân tộc Việt Nam',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withValues(alpha: 0.75))),
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
          Text('Folkify — Học nhạc dân tộc',
              style: AppTextStyles.titleMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              'Lộ trình học từ Beginner → Advanced, kết hợp video bài giảng và sheet nhạc tương ứng.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final InstrumentSummary instrument;
  const _InstrumentCard({required this.instrument});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/learn/${instrument.id}'),
      child: Container(
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
                      Row(
                        children: List.generate(
                          5,
                          (i) => FaIcon(
                            FontAwesomeIcons.star,
                            size: 13,
                            color: i < instrument.difficulty
                                ? const Color(0xFFF59E0B)
                                : AppColors.border,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _lessonCountBadge(instrument.lessonCount),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    instrument.shortDesc,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 110,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              instrument.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.primaryDark,
                child: Center(
                  child: Text(instrument.emoji,
                      style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.65),
                  ],
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
                      FaIcon(FontAwesomeIcons.music,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        instrument.name,
                        style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _bannerBadge(instrument.category),
                ],
              ),
            ),
          ],
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
      child: Text(label,
          style: AppTextStyles.bodySmall
              .copyWith(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _lessonCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count bài học',
        style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
