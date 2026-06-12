// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleDetailDtoImpl _$$ArticleDetailDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ArticleDetailDtoImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  bodyHtml: json['body_html'] as String,
  url: json['url'] as String,
  publishedAt: DateTime.parse(json['published_at'] as String),
  tagList: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  positiveReactionsCount: (json['positive_reactions_count'] as num).toInt(),
  commentsCount: (json['comments_count'] as num).toInt(),
  readingTimeMinutes: (json['reading_time_minutes'] as num).toInt(),
  coverImage: json['cover_image'] as String?,
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ArticleDetailDtoImplToJson(
  _$ArticleDetailDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'body_html': instance.bodyHtml,
  'url': instance.url,
  'published_at': instance.publishedAt.toIso8601String(),
  'tags': instance.tagList,
  'positive_reactions_count': instance.positiveReactionsCount,
  'comments_count': instance.commentsCount,
  'reading_time_minutes': instance.readingTimeMinutes,
  'cover_image': instance.coverImage,
  'user': instance.user,
};
