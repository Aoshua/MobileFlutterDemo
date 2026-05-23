class ApiException implements Exception {
    const ApiException({required this.failure});
    final AppFailure failure;

    @override
    String toString() => 'ApiException($failure)';
}