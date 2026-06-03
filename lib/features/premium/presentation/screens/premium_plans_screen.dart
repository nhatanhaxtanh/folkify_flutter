import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  String _selectedPlan = 'pro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Nâng cấp tài khoản', style: AppTextStyles.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildPlans(),
            const SizedBox(height: 28),
            _buildFeatureList(),
            const SizedBox(height: 32),
            GradientButton(
              text: _selectedPlan == 'pro' ? 'Bắt đầu với Pro — 99.000đ/tháng' : 'Bắt đầu với Basic — 49.000đ/tháng',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng thanh toán sẽ có sớm!'), backgroundColor: AppColors.primary),
                );
              },
              icon: FontAwesomeIcons.crown,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text('Tiếp tục dùng miễn phí', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        FaIcon(FontAwesomeIcons.crown, color: const Color(0xFFF59E0B), size: 56),
        const SizedBox(height: 16),
        Text('Mở khóa toàn bộ\nnội dung Folkify', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Học không giới hạn với hàng trăm bài học và bản nhạc', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPlans() {
    return Column(
      children: [
        _PlanCard(
          planId: 'basic',
          title: 'Basic',
          price: '49.000đ',
          period: '/tháng',
          features: const ['Tất cả bài học cơ bản', '50+ bản nhạc', 'Luyện tập không giới hạn'],
          color: AppColors.planBasic,
          isSelected: _selectedPlan == 'basic',
          onTap: () => setState(() => _selectedPlan = 'basic'),
        ),
        const SizedBox(height: 14),
        _PlanCard(
          planId: 'pro',
          title: 'Pro',
          price: '99.000đ',
          period: '/tháng',
          features: const ['Tất cả bài học & bản nhạc', 'Máy lên dây thông minh', 'Theo dõi tiến trình chi tiết', 'Tải bản nhạc offline', 'Hỗ trợ ưu tiên 24/7'],
          color: AppColors.planPro,
          isSelected: _selectedPlan == 'pro',
          onTap: () => setState(() => _selectedPlan = 'pro'),
          isBest: true,
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      (FontAwesomeIcons.book, 'Học không giới hạn', '100+ bài học từ cơ bản đến nâng cao'),
      (FontAwesomeIcons.listUl, 'Kho bản nhạc phong phú', '200+ bản nhạc dân tộc Việt Nam'),
      (FontAwesomeIcons.download, 'Học offline', 'Tải nội dung để học mà không cần mạng'),
      (FontAwesomeIcons.arrowTrendUp, 'Theo dõi tiến trình', 'Thống kê chi tiết hành trình học tập'),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: FaIcon(f.$1, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.$2, style: AppTextStyles.titleMedium),
                  Text(f.$3, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String planId;
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final Color color;
  final bool isSelected;
  final bool isBest;
  final VoidCallback onTap;

  const _PlanCard({
    required this.planId,
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isBest = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.headlineMedium.copyWith(color: color)),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('PHỔ BIẾN', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price, style: AppTextStyles.headlineLarge.copyWith(color: color)),
                    Text(period, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.circleCheck, color: color, size: 16),
                  const SizedBox(width: 8),
                  Text(f, style: AppTextStyles.bodyMedium),
                ],
              ),
            )),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: FaIcon(FontAwesomeIcons.recordVinyl, color: color, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
