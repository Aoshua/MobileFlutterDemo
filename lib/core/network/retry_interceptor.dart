import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 2});
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && _retriesLeft(err) > 0) {
      final retryCount = _retriesLeft(err) - 1;
      // The 'extra' map on RequestOptions is a free-form Map<String, dynamic>
      // you can use to pass data between interceptors on the same request,
      // here used as a retry counter.
      final options = err.requestOptions..extra['retries'] = retryCount;
      try {
        final response = await Dio().fetch(options);
        // This short-circuits the error chain and returns the response to
        // the caller as if the request succeeded.
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  int _retriesLeft(DioException err) =>
      (err.requestOptions.extra['retries'] as int?) ?? maxRetries;
}
