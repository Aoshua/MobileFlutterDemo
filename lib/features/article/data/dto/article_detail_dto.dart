import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_flutter_demo/features/feed/data/dto/user_dto.dart';

part 'article_detail_dto.freezed.dart';
part 'article_detail_dto.g.dart';

@freezed
class ArticleDetailDto with _$ArticleDetailDto {
  const factory ArticleDetailDto({
    required int id,
    required String title,
    required String description,
    @JsonKey(name: 'body_markdown') required String bodyMarkdown,
    required String url,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    @JsonKey(name: 'tag_list') required List<String> tagList,
    @JsonKey(name: 'positive_reactions_count')
    required int positiveReactionsCount,
    @JsonKey(name: 'comments_count') required int commentsCount,
    @JsonKey(name: 'reading_time_minutes') required int readingTimeMinutes,
    @JsonKey(name: 'cover_image') String? coverImage,
    required UserDto user,
  }) = _ArticleDetailDto;

  factory ArticleDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDetailDtoFromJson(json);
}
