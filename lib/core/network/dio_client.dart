import 'package:dio/dio.dart';
import 'package:mobile_flutter_demo/core/env/app_env.dart';
import 'package:mobile_flutter_demo/core/network/logging_interceptor.dart';
import 'package:mobile_flutter_demo/core/network/retry_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  final env = ref.watch(appEnvProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.devtoBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([LoggingInterceptor(), RetryInterceptor()]);
  return dio;
}
