sealed class AppFailure {
    const AppFailure();
}

final class NetworkFailure extends AppFailure {
    final String? message;
    const NetworkFailure({this.message});
}

final class ServerFailure extends AppFailure {
    final String? message;
    final int statusCode;
    const ServerFailure({required this.statusCode, this.message});
}

final class NotFoundFailure extends AppFailure {
    const NofFoundFailure();
}

final class UnknownFailure extends AppFailure {
    final Object error;
    const UnknownFailure({required this.error});
}