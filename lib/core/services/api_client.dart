import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';
import 'token_storage.dart';

class ApiClient {
  static Dio? _instance;
  static void Function()? onSessionExpired;

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));
    dio.interceptors.add(_AuthInterceptor(dio));
    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<({RequestOptions opts, ErrorInterceptorHandler handler})> _queue = [];

  _AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _queue.add((opts: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        handler.next(err);
        return;
      }

      // Refresh — nếu fail thì throw, catch bên dưới xử lý
      final tokens = await AuthService.refreshAccessToken(refreshToken);
      await TokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final newToken = tokens.accessToken;

      // Retry các request đang chờ
      final pending = List.of(_queue);
      _queue.clear();
      for (final p in pending) {
        p.opts.headers['Authorization'] = 'Bearer $newToken';
        try {
          final r = await dio.fetch(p.opts);
          p.handler.resolve(r);
        } catch (e) {
          p.handler.next(
              e is DioException ? e : DioException(requestOptions: p.opts));
        }
      }

      // Retry request gốc
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(e is DioException
            ? e
            : DioException(requestOptions: err.requestOptions));
      }
    } catch (_) {
      // Chỉ vào đây khi refresh thất bại thực sự
      final pending = List.of(_queue);
      _queue.clear();
      for (final p in pending) {
        p.handler.next(DioException(requestOptions: p.opts));
      }
      await TokenStorage.clearTokens();
      ApiClient.onSessionExpired?.call();
      handler.next(err);
    } finally {
      _queue.clear();
      _isRefreshing = false;
    }
  }
}
