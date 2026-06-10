import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_api.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ArticleRepositoryImpl repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://dev.to/api'));
    adapter = DioAdapter(dio: dio);
    repo = ArticleRepositoryImpl(api: ArticleApi(dio: dio));
  });

  group('getArticles', () {
    test('returns Ok with parsed articles on 200', () async {
      adapter.onGet(
        '/articles',
        (server) => server.reply(200, [
          {
            'id': 1,
            'title': 'Test',
            'description': 'Desc',
            'url': 'https://dev.to/test',
            'user': {'username': 'alice', 'profile_image_90': 'https://img'},
            'cover_image': null,
            'positive_reactions_count': 5,
            'comments_count': 1,
            'published_at': '2024-01-01T00:00:00Z',
            'tag_list': ['flutter'],
          },
        ]),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect(result, isA<Ok<List, AppFailure>>());
      final articles = (result as Ok).value as List;
      expect(articles.length, 1);
      expect(articles.first.title, 'Test');
    });

    test('returns Err(NetworkFailure) on connection timeout', () async {
      adapter.onGet(
        '/articles',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect(result, isA<Err<List, AppFailure>>());
      expect((result as Err).error, isA<NetworkFailure>());
    });

    test('returns Err(NotFoundFailure) on 404', () async {
      adapter.onGet(
        '/articles',
        (server) => server.reply(404, {'error': 'not found'}),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect((result as Err).error, isA<NotFoundFailure>());
    });
  });
}
