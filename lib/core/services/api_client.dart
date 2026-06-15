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
      if (refreshToken != null) {
        final tokens = await AuthService.refreshAccessToken(refreshToken);
        await TokenStorage.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        );
        final newToken = tokens.accessToken;

        // Retry original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);

        // Retry all queued requests
        for (final pending in _queue) {
          pending.opts.headers['Authorization'] = 'Bearer $newToken';
          try {
            final r = await dio.fetch(pending.opts);
            pending.handler.resolve(r);
          } catch (e) {
            pending.handler.next(e is DioException ? e : DioException(requestOptions: pending.opts));
          }
        }
        return;
      }
    } catch (_) {
      for (final pending in _queue) {
        pending.handler.next(DioException(requestOptions: pending.opts));
      }
      await TokenStorage.clearTokens();
      ApiClient.onSessionExpired?.call();
    } finally {
      _queue.clear();
      _isRefreshing = false;
    }

    handler.next(err);
  }
}
