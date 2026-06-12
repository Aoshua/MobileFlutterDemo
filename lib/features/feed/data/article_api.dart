import 'package:dio/dio.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'package:mobile_flutter_demo/features/feed/data/dto/article_dto.dart';

class ArticleApi {
  const ArticleApi({required this.dio});
  final Dio dio;

  Future<List<ArticleDto>> fetchArticles({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/articles',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data; // Dynamic until cast
      if (data == null) throw const ApiException(failure: NetworkFailure());
      return data
          .cast<Map<String, dynamic>>() // Cast here
          .map(ArticleDto.fromJson)
          .toList();
    } on DioException catch (e) {
      // This is the only place in the app that DioException is caught,
      // everything else sees only ApiException with a mapped AppFailure
      throw ApiException(failure: _mapDioError(e));
    }
  }

  AppFailure _mapDioError(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout => NetworkFailure(message: e.message),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
      404 => const NotFoundFailure(),
      _ => ServerFailure(statusCode: e.response?.statusCode ?? 0),
    },
    _ => UnknownFailure(error: e),
  };
}
