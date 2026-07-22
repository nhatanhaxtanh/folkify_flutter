import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';
import 'iap_provider.dart';

enum Pay2sPhase { idle, creating, waiting, success, expired, error }

class Pay2sState {
  final Pay2sPhase phase;
  final String? orderId;
  final String? payUrl;
  final String? plan; // "BASIC" | "PRO"
  final String? message;

  const Pay2sState({
    this.phase = Pay2sPhase.idle,
    this.orderId,
    this.payUrl,
    this.plan,
    this.message,
  });

  Pay2sState copyWith({
    Pay2sPhase? phase,
    String? orderId,
    String? payUrl,
    String? plan,
    String? message,
  }) {
    return Pay2sState(
      phase: phase ?? this.phase,
      orderId: orderId ?? this.orderId,
      payUrl: payUrl ?? this.payUrl,
      plan: plan ?? this.plan,
      message: message ?? this.message,
    );
  }
}

/// Map gói backend → product id để đồng bộ trạng thái premium với IAP provider.
String _productIdForPlan(String plan) =>
    plan == 'PRO' ? kProPlanId : kBasicPlanId;

class Pay2sNotifier extends AutoDisposeNotifier<Pay2sState> {
  Timer? _pollTimer;
  DateTime? _deadline;

  @override
  Pay2sState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return const Pay2sState();
  }

  /// Bắt đầu luồng: tạo link → mở trang thanh toán → poll trạng thái.
  Future<void> start(String plan) async {
    _pollTimer?.cancel();
    state = Pay2sState(phase: Pay2sPhase.creating, plan: plan);

    try {
      final checkout = await PaymentService.createCheckout(plan);
      state = state.copyWith(
        phase: Pay2sPhase.waiting,
        orderId: checkout.orderId,
        payUrl: checkout.payUrl,
      );
      await openPayUrl();
      _startPolling();
    } catch (e) {
      state = state.copyWith(phase: Pay2sPhase.error, message: e.toString());
    }
  }

  /// Mở lại trang thanh toán Pay2S trên trình duyệt ngoài.
  Future<bool> openPayUrl() async {
    final url = state.payUrl;
    if (url == null) return false;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  void _startPolling() {
    _deadline = DateTime.now().add(const Duration(minutes: 15));
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    final orderId = state.orderId;
    if (orderId == null) return;

    if (_deadline != null && DateTime.now().isAfter(_deadline!)) {
      _pollTimer?.cancel();
      state = state.copyWith(
        phase: Pay2sPhase.expired,
        message: 'Giao dịch đã hết hạn. Vui lòng thử lại.',
      );
      return;
    }

    try {
      final status = await PaymentService.getStatus(orderId);
      if (status.isSuccess) {
        _pollTimer?.cancel();
        await _unlockPremium(status.targetPlan ?? state.plan);
        state = state.copyWith(phase: Pay2sPhase.success);
      } else if (status.isFinished) {
        _pollTimer?.cancel();
        state = state.copyWith(
          phase: Pay2sPhase.expired,
          message: 'Giao dịch chưa hoàn tất. Vui lòng thử lại.',
        );
      }
    } catch (_) {
      // Lỗi mạng tạm thời — bỏ qua, lần poll sau thử lại.
    }
  }

  /// Lưu trạng thái premium và làm mới IAP provider để cả app nhận gói mới.
  Future<void> _unlockPremium(String? plan) async {
    if (plan == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('folkify_active_plan', _productIdForPlan(plan));
    ref.invalidate(iapProvider);
  }

  /// Poll thủ công ngay (khi user bấm "Tôi đã thanh toán").
  Future<void> checkNow() => _poll();

  void reset() {
    _pollTimer?.cancel();
    state = const Pay2sState();
  }
}

final pay2sProvider =
    AutoDisposeNotifierProvider<Pay2sNotifier, Pay2sState>(Pay2sNotifier.new);
