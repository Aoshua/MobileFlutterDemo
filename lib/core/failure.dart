sealed class AppFailure {
  const AppFailure();
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({this.message});
  final String? message;
}

final class ServerFailure extends AppFailure {
  const ServerFailure({required this.statusCode, this.message});
  final String? message;
  final int statusCode;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({required this.error});
  final Object error;
}
