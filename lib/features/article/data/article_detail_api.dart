import 'package:dio/dio.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'dto/article_detail_dto.dart';

class ArticleDetailApi {
  const ArticleDetailApi({required this.dio});
  final Dio dio;

  Future<ArticleDetailDto> fetchArticle({required int id}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/articles/$id');
      final data = response.data;
      if (data == null) throw const ApiException(failure: NetworkFailure());
      return ArticleDetailDto.fromJson(data);
    } on DioException catch (e) {
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
