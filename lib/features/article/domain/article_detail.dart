import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_detail.freezed.dart';

@freezed
class ArticleDetail with _$ArticleDetail {
  const factory ArticleDetail({
    required int id,
    required String title,
    required String description,
    required String bodyMarkdown,
    required String url,
    required String username,
    required String userProfileImage,
    required int positiveReactionsCount,
    required int commentsCount,
    required int readingTimeMinutes,
    required DateTime publishedAt,
    required List<String> tags,
    String? coverImageUrl,
  }) = _ArticleDetail;
}
