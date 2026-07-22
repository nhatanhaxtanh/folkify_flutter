import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/payment_provider.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Màn thanh toán qua Pay2S (chuyển khoản/QR ngân hàng).
class Pay2sCheckoutScreen extends ConsumerStatefulWidget {
  final String plan; // "BASIC" | "PRO"
  const Pay2sCheckoutScreen({super.key, required this.plan});

  @override
  ConsumerState<Pay2sCheckoutScreen> createState() => _Pay2sCheckoutScreenState();
}

class _Pay2sCheckoutScreenState extends ConsumerState<Pay2sCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pay2sProvider.notifier).start(widget.plan);
    });
  }

  String get _planLabel => widget.plan == 'PRO' ? 'Pro' : 'Basic';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pay2sProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Thanh toán gói $_planLabel', style: AppTextStyles.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(child: _buildBody(state)),
      ),
    );
  }

  Widget _buildBody(Pay2sState state) {
    switch (state.phase) {
      case Pay2sPhase.creating:
        return _loading('Đang tạo giao dịch...');

      case Pay2sPhase.waiting:
        return _waiting();

      case Pay2sPhase.success:
        return _result(
          icon: FontAwesomeIcons.circleCheck,
          color: const Color(0xFF16A34A),
          title: 'Thanh toán thành công!',
          subtitle: 'Gói $_planLabel đã được kích hoạt. Chúc bạn học vui!',
          buttonText: 'Hoàn tất',
          onPressed: () => context.pop(true),
        );

      case Pay2sPhase.expired:
        return _result(
          icon: FontAwesomeIcons.clock,
          color: AppColors.textMuted,
          title: 'Giao dịch chưa hoàn tất',
          subtitle: state.message ?? 'Vui lòng thử lại.',
          buttonText: 'Thử lại',
          onPressed: () => ref.read(pay2sProvider.notifier).start(widget.plan),
        );

      case Pay2sPhase.error:
        return _result(
          icon: FontAwesomeIcons.circleExclamation,
          color: AppColors.error,
          title: 'Có lỗi xảy ra',
          subtitle: state.message ?? 'Không thể tạo giao dịch.',
          buttonText: 'Thử lại',
          onPressed: () => ref.read(pay2sProvider.notifier).start(widget.plan),
        );

      case Pay2sPhase.idle:
        return _loading('Đang chuẩn bị...');
    }
  }

  Widget _loading(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(text, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _waiting() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(FontAwesomeIcons.qrcode, size: 56, color: AppColors.primary),
        const SizedBox(height: 20),
        Text('Đang chờ thanh toán', style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Trang thanh toán đã mở trên trình duyệt. Hãy quét mã QR hoặc '
          'chuyển khoản đúng nội dung. Trạng thái sẽ tự cập nhật sau khi tiền về.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        const SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(height: 28),
        GradientButton(
          text: 'Mở lại trang thanh toán',
          icon: FontAwesomeIcons.arrowUpRightFromSquare,
          onPressed: () => ref.read(pay2sProvider.notifier).openPayUrl(),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.read(pay2sProvider.notifier).checkNow(),
          child: Text(
            'Tôi đã thanh toán — kiểm tra ngay',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _result({
    required FaIconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 64, color: color),
        const SizedBox(height: 20),
        Text(title, style: AppTextStyles.displayMedium, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        GradientButton(text: buttonText, onPressed: onPressed),
      ],
    );
  }
}
