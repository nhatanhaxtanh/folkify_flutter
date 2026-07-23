import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Kết quả tạo link thanh toán Pay2S.
class Pay2sCheckout {
  final String payUrl;
  final String orderId;

  const Pay2sCheckout({required this.payUrl, required this.orderId});

  factory Pay2sCheckout.fromJson(Map<String, dynamic> json) => Pay2sCheckout(
        payUrl: json['payUrl'] as String,
        orderId: json['orderId'] as String,
      );
}

/// Trạng thái giao dịch trả về khi poll.
class Pay2sStatus {
  final String orderId;
  final String status; // PENDING | SUCCESS | CANCELLED | FAILED
  final String? targetPlan;

  const Pay2sStatus({
    required this.orderId,
    required this.status,
    this.targetPlan,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isPending => status == 'PENDING';
  bool get isFinished => status != 'PENDING';

  factory Pay2sStatus.fromJson(Map<String, dynamic> json) => Pay2sStatus(
        orderId: json['orderId'] as String,
        status: json['status'] as String,
        targetPlan: json['targetPlan'] as String?,
      );
}

class PaymentService {
  static final _dio = ApiClient.instance;

  /// Tạo link thanh toán Pay2S để nâng cấp gói ("BASIC" | "PRO").
  /// Timeout dài hơn vì backend còn gọi tiếp sang Pay2S (lần đầu có thể chậm).
  static Future<Pay2sCheckout> createCheckout(String plan) async {
    try {
      final res = await _dio.post(
        '/api/payments/checkout',
        data: {'plan': plan},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      return Pay2sCheckout.fromJson(res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  /// Kiểm tra trạng thái giao dịch theo orderId.
  static Future<Pay2sStatus> getStatus(String orderId) async {
    try {
      final res = await _dio.get('/api/payments/status/$orderId');
      return Pay2sStatus.fromJson(res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'] as String;
      }
    } catch (_) {}
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Kết nối quá thời gian, vui lòng thử lại',
      DioExceptionType.connectionError => 'Không thể kết nối máy chủ',
      _ => 'Lỗi không xác định',
    };
  }
}
