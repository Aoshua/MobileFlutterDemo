import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_flutter_demo/features/feed/data/dto/user_dto.dart';

part 'article_dto.freezed.dart';
part 'article_dto.g.dart';

// All the snake_case -> camelCase renaming happens here in the DTO,
// so the domain model and all widgets use idiomatic Dart naming.

@freezed
class ArticleDto with _$ArticleDto {
  const factory ArticleDto({
    required int id,
    required String title,
    required String description,
    required String url,
    required UserDto user,
    @JsonKey(name: 'positive_reactions_count')
    required int positiveReactionsCount,
    @JsonKey(name: 'comments_count')
    required int
    commentsCount, // json_serializable knows how to parse ISO 8601 date strings to
    // DateTime automatically.
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    @JsonKey(name: 'tag_list') required List<String> tagList,
    @JsonKey(name: 'cover_image') String? coverImage,
  }) = _ArticleDto;

  factory ArticleDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDtoFromJson(json);
}
