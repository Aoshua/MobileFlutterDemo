// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArticleDetailDto _$ArticleDetailDtoFromJson(Map<String, dynamic> json) {
  return _ArticleDetailDto.fromJson(json);
}

/// @nodoc
mixin _$ArticleDetailDto {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'body_html')
  String get bodyHtml => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_at')
  DateTime get publishedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'tags')
  List<String> get tagList => throw _privateConstructorUsedError;
  @JsonKey(name: 'positive_reactions_count')
  int get positiveReactionsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comments_count')
  int get commentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'reading_time_minutes')
  int get readingTimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String? get coverImage => throw _privateConstructorUsedError;
  UserDto get user => throw _privateConstructorUsedError;

  /// Serializes this ArticleDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleDetailDtoCopyWith<ArticleDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleDetailDtoCopyWith<$Res> {
  factory $ArticleDetailDtoCopyWith(
    ArticleDetailDto value,
    $Res Function(ArticleDetailDto) then,
  ) = _$ArticleDetailDtoCopyWithImpl<$Res, ArticleDetailDto>;
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    @JsonKey(name: 'body_html') String bodyHtml,
    String url,
    @JsonKey(name: 'published_at') DateTime publishedAt,
    @JsonKey(name: 'tags') List<String> tagList,
    @JsonKey(name: 'positive_reactions_count') int positiveReactionsCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'reading_time_minutes') int readingTimeMinutes,
    @JsonKey(name: 'cover_image') String? coverImage,
    UserDto user,
  });

  $UserDtoCopyWith<$Res> get user;
}

/// @nodoc
class _$ArticleDetailDtoCopyWithImpl<$Res, $Val extends ArticleDetailDto>
    implements $ArticleDetailDtoCopyWith<$Res> {
  _$ArticleDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? bodyHtml = null,
    Object? url = null,
    Object? publishedAt = null,
    Object? tagList = null,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? readingTimeMinutes = null,
    Object? coverImage = freezed,
    Object? user = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyHtml: null == bodyHtml
                ? _value.bodyHtml
                : bodyHtml // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tagList: null == tagList
                ? _value.tagList
                : tagList // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            positiveReactionsCount: null == positiveReactionsCount
                ? _value.positiveReactionsCount
                : positiveReactionsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsCount: null == commentsCount
                ? _value.commentsCount
                : commentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            readingTimeMinutes: null == readingTimeMinutes
                ? _value.readingTimeMinutes
                : readingTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            coverImage: freezed == coverImage
                ? _value.coverImage
                : coverImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserDto,
          )
          as $Val,
    );
  }

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoCopyWith<$Res> get user {
    return $UserDtoCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ArticleDetailDtoImplCopyWith<$Res>
    implements $ArticleDetailDtoCopyWith<$Res> {
  factory _$$ArticleDetailDtoImplCopyWith(
    _$ArticleDetailDtoImpl value,
    $Res Function(_$ArticleDetailDtoImpl) then,
  ) = __$$ArticleDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    @JsonKey(name: 'body_html') String bodyHtml,
    String url,
    @JsonKey(name: 'published_at') DateTime publishedAt,
    @JsonKey(name: 'tags') List<String> tagList,
    @JsonKey(name: 'positive_reactions_count') int positiveReactionsCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'reading_time_minutes') int readingTimeMinutes,
    @JsonKey(name: 'cover_image') String? coverImage,
    UserDto user,
  });

  @override
  $UserDtoCopyWith<$Res> get user;
}

/// @nodoc
class __$$ArticleDetailDtoImplCopyWithImpl<$Res>
    extends _$ArticleDetailDtoCopyWithImpl<$Res, _$ArticleDetailDtoImpl>
    implements _$$ArticleDetailDtoImplCopyWith<$Res> {
  __$$ArticleDetailDtoImplCopyWithImpl(
    _$ArticleDetailDtoImpl _value,
    $Res Function(_$ArticleDetailDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? bodyHtml = null,
    Object? url = null,
    Object? publishedAt = null,
    Object? tagList = null,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? readingTimeMinutes = null,
    Object? coverImage = freezed,
    Object? user = null,
  }) {
    return _then(
      _$ArticleDetailDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyHtml: null == bodyHtml
            ? _value.bodyHtml
            : bodyHtml // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tagList: null == tagList
            ? _value._tagList
            : tagList // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        positiveReactionsCount: null == positiveReactionsCount
            ? _value.positiveReactionsCount
            : positiveReactionsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsCount: null == commentsCount
            ? _value.commentsCount
            : commentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        readingTimeMinutes: null == readingTimeMinutes
            ? _value.readingTimeMinutes
            : readingTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        coverImage: freezed == coverImage
            ? _value.coverImage
            : coverImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserDto,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleDetailDtoImpl implements _ArticleDetailDto {
  const _$ArticleDetailDtoImpl({
    required this.id,
    required this.title,
    required this.description,
    @JsonKey(name: 'body_html') required this.bodyHtml,
    required this.url,
    @JsonKey(name: 'published_at') required this.publishedAt,
    @JsonKey(name: 'tags') required final List<String> tagList,
    @JsonKey(name: 'positive_reactions_count')
    required this.positiveReactionsCount,
    @JsonKey(name: 'comments_count') required this.commentsCount,
    @JsonKey(name: 'reading_time_minutes') required this.readingTimeMinutes,
    @JsonKey(name: 'cover_image') this.coverImage,
    required this.user,
  }) : _tagList = tagList;

  factory _$ArticleDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleDetailDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'body_html')
  final String bodyHtml;
  @override
  final String url;
  @override
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;
  final List<String> _tagList;
  @override
  @JsonKey(name: 'tags')
  List<String> get tagList {
    if (_tagList is EqualUnmodifiableListView) return _tagList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagList);
  }

  @override
  @JsonKey(name: 'positive_reactions_count')
  final int positiveReactionsCount;
  @override
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @override
  @JsonKey(name: 'reading_time_minutes')
  final int readingTimeMinutes;
  @override
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @override
  final UserDto user;

  @override
  String toString() {
    return 'ArticleDetailDto(id: $id, title: $title, description: $description, bodyHtml: $bodyHtml, url: $url, publishedAt: $publishedAt, tagList: $tagList, positiveReactionsCount: $positiveReactionsCount, commentsCount: $commentsCount, readingTimeMinutes: $readingTimeMinutes, coverImage: $coverImage, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.bodyHtml, bodyHtml) ||
                other.bodyHtml == bodyHtml) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            const DeepCollectionEquality().equals(other._tagList, _tagList) &&
            (identical(other.positiveReactionsCount, positiveReactionsCount) ||
                other.positiveReactionsCount == positiveReactionsCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.readingTimeMinutes, readingTimeMinutes) ||
                other.readingTimeMinutes == readingTimeMinutes) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    bodyHtml,
    url,
    publishedAt,
    const DeepCollectionEquality().hash(_tagList),
    positiveReactionsCount,
    commentsCount,
    readingTimeMinutes,
    coverImage,
    user,
  );

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleDetailDtoImplCopyWith<_$ArticleDetailDtoImpl> get copyWith =>
      __$$ArticleDetailDtoImplCopyWithImpl<_$ArticleDetailDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleDetailDtoImplToJson(this);
  }
}

abstract class _ArticleDetailDto implements ArticleDetailDto {
  const factory _ArticleDetailDto({
    required final int id,
    required final String title,
    required final String description,
    @JsonKey(name: 'body_html') required final String bodyHtml,
    required final String url,
    @JsonKey(name: 'published_at') required final DateTime publishedAt,
    @JsonKey(name: 'tags') required final List<String> tagList,
    @JsonKey(name: 'positive_reactions_count')
    required final int positiveReactionsCount,
    @JsonKey(name: 'comments_count') required final int commentsCount,
    @JsonKey(name: 'reading_time_minutes')
    required final int readingTimeMinutes,
    @JsonKey(name: 'cover_image') final String? coverImage,
    required final UserDto user,
  }) = _$ArticleDetailDtoImpl;

  factory _ArticleDetailDto.fromJson(Map<String, dynamic> json) =
      _$ArticleDetailDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'body_html')
  String get bodyHtml;
  @override
  String get url;
  @override
  @JsonKey(name: 'published_at')
  DateTime get publishedAt;
  @override
  @JsonKey(name: 'tags')
  List<String> get tagList;
  @override
  @JsonKey(name: 'positive_reactions_count')
  int get positiveReactionsCount;
  @override
  @JsonKey(name: 'comments_count')
  int get commentsCount;
  @override
  @JsonKey(name: 'reading_time_minutes')
  int get readingTimeMinutes;
  @override
  @JsonKey(name: 'cover_image')
  String? get coverImage;
  @override
  UserDto get user;

  /// Create a copy of ArticleDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleDetailDtoImplCopyWith<_$ArticleDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
