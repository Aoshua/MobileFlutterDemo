import 'package:mobile_flutter_demo/core/failure.dart';

class ApiException implements Exception {
  const ApiException({required this.failure});
  final AppFailure failure;

  @override
  String toString() => 'ApiException($failure)';
}
