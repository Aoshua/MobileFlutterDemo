import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
    @override
    void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
        // kDebugMode is a compile-time constant that is true in debug builds and false in release builds.
        if (kDebugMode) {
            print('[HTTP] -> ${options.method} ${options.uri}');
        }
        // Always pass the request/response/error along the chain, otherwise the request will be blocked.
        handler.next(options);
    }

    @override
    void onResponse(Response response, ResponseInterceptorHandler handler) {
        if (kDebugMode) {
            print('[HTTP] <- ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
    }

    @override
    void onError(DioError err, ErrorInterceptorHandler handler) {
        if (kDebugMode) {
            print('[HTTP] X ${err.requestOptions.uri} - ${err.message}');
        }
        handler.next(err);
    }
}