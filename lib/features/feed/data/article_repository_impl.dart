import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'package:mobile_flutter_demo/core/network/dio_client.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_api.dart';
import 'package:mobile_flutter_demo/features/feed/data/dto/article_dto.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_repository_impl.g.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl({required this.api});
  final ArticleApi api;

  @override
  Future<Result<List<Article>, AppFailure>> getArticles({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final dtos = await api.fetchArticles(page: page, perPage: perPage);
      return Ok(dtos.map(_toArticle).toList());
    } on ApiException catch (e) {
      return Err(e.failure);
    } catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  Article _toArticle(ArticleDto dto) => Article(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    url: dto.url,
    username: dto.user.username,
    userProfileImage: dto.user.profileImage,
    coverImageUrl: dto.coverImage,
    positiveReactionsCount: dto.positiveReactionsCount,
    commentsCount: dto.commentsCount,
    publishedAt: dto.publishedAt,
    tags: dto.tagList,
  );
}

@riverpod
ArticleRepository articleRepository(ArticleRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ArticleRepositoryImpl(api: ArticleApi(dio: dio));
}
