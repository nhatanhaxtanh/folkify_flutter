import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/iap_provider.dart';
import '../../../../core/widgets/gradient_button.dart';

class PremiumPlansScreen extends ConsumerStatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  ConsumerState<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends ConsumerState<PremiumPlansScreen> {
  String _selectedPlanId = kProPlanId;

  ProductDetails? _findProduct(List<ProductDetails> products, String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _purchase() async {
    final iap = ref.read(iapProvider);

    if (!iap.isStoreAvailable) {
      final detail = iap.purchaseError != null ? '\n${iap.purchaseError}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App Store không khả dụng$detail'),
          duration: const Duration(seconds: 8),
        ),
      );
      return;
    }

    final product = _findProduct(iap.products, _selectedPlanId);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tải được thông tin sản phẩm. Vui lòng thử lại sau.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(iapProvider.notifier).purchase(product);
  }

  Future<void> _restore() async {
    await ref.read(iapProvider.notifier).restore();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang khôi phục giao dịch...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iap = ref.watch(iapProvider);

    // Hiển thị thông báo lỗi khi có
    ref.listen(iapProvider, (prev, next) {
      if (next.purchaseError != null && prev?.purchaseError != next.purchaseError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.purchaseError!), backgroundColor: AppColors.error),
        );
      }
      if (next.isPremium && !(prev?.isPremium ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Chào mừng bạn đến với Premium'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      }
    });

    final basicProduct = _findProduct(iap.products, kBasicPlanId);
    final proProduct = _findProduct(iap.products, kProPlanId);

    String buttonText;
    if (iap.isPremium) {
      buttonText = 'Đang hoạt động';
    } else if (_selectedPlanId == kProPlanId) {
      buttonText = 'Bắt đầu với Pro — ${proProduct?.price ?? '99.000đ'}/tháng';
    } else {
      buttonText = 'Bắt đầu với Basic — ${basicProduct?.price ?? '49.000đ'}/tháng';
    }

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
      body: iap.isLoading && iap.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(iap),
                  const SizedBox(height: 32),
                  _buildPlans(iap, basicProduct, proProduct),
                  const SizedBox(height: 28),
                  _buildFeatureList(),
                  const SizedBox(height: 32),
                  GradientButton(
                    text: buttonText,
                    isLoading: iap.isLoading,
                    onPressed: iap.isPremium ? null : _purchase,
                    icon: FontAwesomeIcons.crown,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: iap.isLoading ? null : _restore,
                    child: Text(
                      'Khôi phục giao dịch',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Subscription tự động gia hạn trừ khi hủy trước 24 giờ khi hết kỳ. Quản lý trong App Store Settings.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse('https://folkify.vn/privacy'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          'Chính sách bảo mật',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          'Điều khoản sử dụng',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(IapState iap) {
    return Column(
      children: [
        FaIcon(FontAwesomeIcons.crown, color: const Color(0xFFF59E0B), size: 56),
        const SizedBox(height: 16),
        if (iap.isPremium) ...[
          Text('Bạn đang là thành viên Premium', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                const SizedBox(width: 8),
                Text(
                  iap.activePlanId == kProPlanId ? 'Gói Pro đang hoạt động' : 'Gói Basic đang hoạt động',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text('Mở khóa toàn bộ\nnội dung Folkify', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Học không giới hạn với hàng trăm bài học và bản nhạc',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPlans(IapState iap, ProductDetails? basicProduct, ProductDetails? proProduct) {
    return Column(
      children: [
        _PlanCard(
          planId: kBasicPlanId,
          title: 'Basic',
          price: basicProduct?.price ?? '49.000đ',
          period: '/tháng',
          features: const ['Tất cả bài học cơ bản', '50+ bản nhạc', 'Luyện tập không giới hạn'],
          color: AppColors.planBasic,
          isSelected: _selectedPlanId == kBasicPlanId,
          isActive: iap.activePlanId == kBasicPlanId,
          onTap: () => setState(() => _selectedPlanId = kBasicPlanId),
        ),
        const SizedBox(height: 14),
        _PlanCard(
          planId: kProPlanId,
          title: 'Pro',
          price: proProduct?.price ?? '99.000đ',
          period: '/tháng',
          features: const [
            'Tất cả bài học & bản nhạc',
            'Máy lên dây thông minh',
            'Theo dõi tiến trình chi tiết',
            'Tải bản nhạc offline',
            'Hỗ trợ ưu tiên 24/7',
          ],
          color: AppColors.planPro,
          isSelected: _selectedPlanId == kProPlanId,
          isActive: iap.activePlanId == kProPlanId,
          onTap: () => setState(() => _selectedPlanId = kProPlanId),
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
  final bool isActive;
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
    required this.isActive,
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
                        child: Text(
                          'PHỔ BIẾN',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ĐANG DÙNG',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
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
          ],
        ),
      ),
    );
  }
}
