import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';

@freezed
class Article with _$Article {
  const factory Article({
    required int id,
    required String title,
    required String description,
    required String url,
    required String username,
    required String userProfileImage,
    String? coverImageUrl,
    required int positiveReactionsCount,
    required int commentsCount,
    required DateTime publishedAt,
    required List<String> tags,
  }) = _Article;
}
