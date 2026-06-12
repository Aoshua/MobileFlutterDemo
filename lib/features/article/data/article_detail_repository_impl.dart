import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'package:mobile_flutter_demo/core/network/dio_client.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_api.dart';
import 'package:mobile_flutter_demo/features/article/data/dto/article_detail_dto.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_detail_repository_impl.g.dart';

class ArticleDetailRepositoryImpl implements ArticleDetailRepository {
  const ArticleDetailRepositoryImpl({required this.api});
  final ArticleDetailApi api;

  @override
  Future<Result<ArticleDetail, AppFailure>> getArticleDetail({
    required int id,
  }) async {
    try {
      final dto = await api.fetchArticle(id: id);
      return Ok(_toArticleDetail(dto));
    } on ApiException catch (e) {
      return Err(e.failure);
    } catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  ArticleDetail _toArticleDetail(ArticleDetailDto dto) => ArticleDetail(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    bodyMarkdown: dto.bodyMarkdown,
    url: dto.url,
    username: dto.user.username,
    userProfileImage: dto.user.profileImage,
    coverImageUrl: dto.coverImage,
    positiveReactionsCount: dto.positiveReactionsCount,
    commentsCount: dto.commentsCount,
    readingTimeMinutes: dto.readingTimeMinutes,
    publishedAt: dto.publishedAt,
    tags: dto.tagList,
  );
}

@riverpod
ArticleDetailRepository articleDetailRepository(
  ArticleDetailRepositoryRef ref,
) {
  final dio = ref.watch(dioClientProvider);
  return ArticleDetailRepositoryImpl(api: ArticleDetailApi(dio: dio));
}
