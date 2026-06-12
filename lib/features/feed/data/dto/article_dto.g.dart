// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleDtoImpl _$$ArticleDtoImplFromJson(Map<String, dynamic> json) =>
    _$ArticleDtoImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      positiveReactionsCount: (json['positive_reactions_count'] as num).toInt(),
      commentsCount: (json['comments_count'] as num).toInt(),
      publishedAt: DateTime.parse(json['published_at'] as String),
      tagList: (json['tag_list'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      coverImage: json['cover_image'] as String?,
    );

Map<String, dynamic> _$$ArticleDtoImplToJson(_$ArticleDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'user': instance.user,
      'positive_reactions_count': instance.positiveReactionsCount,
      'comments_count': instance.commentsCount,
      'published_at': instance.publishedAt.toIso8601String(),
      'tag_list': instance.tagList,
      'cover_image': instance.coverImage,
    };
