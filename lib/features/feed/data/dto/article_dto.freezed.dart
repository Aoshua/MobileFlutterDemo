// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ArticleDto _$ArticleDtoFromJson(Map<String, dynamic> json) {
  return _ArticleDto.fromJson(json);
}

/// @nodoc
mixin _$ArticleDto {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  UserDto get user => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String? get coverImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'positive_reqactions_count')
  int get positiveReactionsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'comments_count')
  int get commentsCount => throw _privateConstructorUsedError; // json_serializable knows how to parse ISO 8601 date strings to
  // DateTime automatically.
  @JsonKey(name: 'published_at')
  DateTime get publishedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'tag_list')
  List<String> get tagList => throw _privateConstructorUsedError;

  /// Serializes this ArticleDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleDtoCopyWith<ArticleDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleDtoCopyWith<$Res> {
  factory $ArticleDtoCopyWith(
    ArticleDto value,
    $Res Function(ArticleDto) then,
  ) = _$ArticleDtoCopyWithImpl<$Res, ArticleDto>;
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String url,
    UserDto user,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'positive_reqactions_count') int positiveReactionsCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'published_at') DateTime publishedAt,
    @JsonKey(name: 'tag_list') List<String> tagList,
  });

  $UserDtoCopyWith<$Res> get user;
}

/// @nodoc
class _$ArticleDtoCopyWithImpl<$Res, $Val extends ArticleDto>
    implements $ArticleDtoCopyWith<$Res> {
  _$ArticleDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? user = null,
    Object? coverImage = freezed,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? publishedAt = null,
    Object? tagList = null,
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
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserDto,
            coverImage: freezed == coverImage
                ? _value.coverImage
                : coverImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            positiveReactionsCount: null == positiveReactionsCount
                ? _value.positiveReactionsCount
                : positiveReactionsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsCount: null == commentsCount
                ? _value.commentsCount
                : commentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tagList: null == tagList
                ? _value.tagList
                : tagList // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of ArticleDto
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
abstract class _$$ArticleDtoImplCopyWith<$Res>
    implements $ArticleDtoCopyWith<$Res> {
  factory _$$ArticleDtoImplCopyWith(
    _$ArticleDtoImpl value,
    $Res Function(_$ArticleDtoImpl) then,
  ) = __$$ArticleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String url,
    UserDto user,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'positive_reqactions_count') int positiveReactionsCount,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'published_at') DateTime publishedAt,
    @JsonKey(name: 'tag_list') List<String> tagList,
  });

  @override
  $UserDtoCopyWith<$Res> get user;
}

/// @nodoc
class __$$ArticleDtoImplCopyWithImpl<$Res>
    extends _$ArticleDtoCopyWithImpl<$Res, _$ArticleDtoImpl>
    implements _$$ArticleDtoImplCopyWith<$Res> {
  __$$ArticleDtoImplCopyWithImpl(
    _$ArticleDtoImpl _value,
    $Res Function(_$ArticleDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? user = null,
    Object? coverImage = freezed,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? publishedAt = null,
    Object? tagList = null,
  }) {
    return _then(
      _$ArticleDtoImpl(
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
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserDto,
        coverImage: freezed == coverImage
            ? _value.coverImage
            : coverImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        positiveReactionsCount: null == positiveReactionsCount
            ? _value.positiveReactionsCount
            : positiveReactionsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsCount: null == commentsCount
            ? _value.commentsCount
            : commentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tagList: null == tagList
            ? _value._tagList
            : tagList // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleDtoImpl implements _ArticleDto {
  const _$ArticleDtoImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.user,
    @JsonKey(name: 'cover_image') this.coverImage,
    @JsonKey(name: 'positive_reqactions_count')
    required this.positiveReactionsCount,
    @JsonKey(name: 'comments_count') required this.commentsCount,
    @JsonKey(name: 'published_at') required this.publishedAt,
    @JsonKey(name: 'tag_list') required final List<String> tagList,
  }) : _tagList = tagList;

  factory _$ArticleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String url;
  @override
  final UserDto user;
  @override
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @override
  @JsonKey(name: 'positive_reqactions_count')
  final int positiveReactionsCount;
  @override
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  // json_serializable knows how to parse ISO 8601 date strings to
  // DateTime automatically.
  @override
  @JsonKey(name: 'published_at')
  final DateTime publishedAt;
  final List<String> _tagList;
  @override
  @JsonKey(name: 'tag_list')
  List<String> get tagList {
    if (_tagList is EqualUnmodifiableListView) return _tagList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagList);
  }

  @override
  String toString() {
    return 'ArticleDto(id: $id, title: $title, description: $description, url: $url, user: $user, coverImage: $coverImage, positiveReactionsCount: $positiveReactionsCount, commentsCount: $commentsCount, publishedAt: $publishedAt, tagList: $tagList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.positiveReactionsCount, positiveReactionsCount) ||
                other.positiveReactionsCount == positiveReactionsCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            const DeepCollectionEquality().equals(other._tagList, _tagList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    url,
    user,
    coverImage,
    positiveReactionsCount,
    commentsCount,
    publishedAt,
    const DeepCollectionEquality().hash(_tagList),
  );

  /// Create a copy of ArticleDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleDtoImplCopyWith<_$ArticleDtoImpl> get copyWith =>
      __$$ArticleDtoImplCopyWithImpl<_$ArticleDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleDtoImplToJson(this);
  }
}

abstract class _ArticleDto implements ArticleDto {
  const factory _ArticleDto({
    required final int id,
    required final String title,
    required final String description,
    required final String url,
    required final UserDto user,
    @JsonKey(name: 'cover_image') final String? coverImage,
    @JsonKey(name: 'positive_reqactions_count')
    required final int positiveReactionsCount,
    @JsonKey(name: 'comments_count') required final int commentsCount,
    @JsonKey(name: 'published_at') required final DateTime publishedAt,
    @JsonKey(name: 'tag_list') required final List<String> tagList,
  }) = _$ArticleDtoImpl;

  factory _ArticleDto.fromJson(Map<String, dynamic> json) =
      _$ArticleDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get url;
  @override
  UserDto get user;
  @override
  @JsonKey(name: 'cover_image')
  String? get coverImage;
  @override
  @JsonKey(name: 'positive_reqactions_count')
  int get positiveReactionsCount;
  @override
  @JsonKey(name: 'comments_count')
  int get commentsCount; // json_serializable knows how to parse ISO 8601 date strings to
  // DateTime automatically.
  @override
  @JsonKey(name: 'published_at')
  DateTime get publishedAt;
  @override
  @JsonKey(name: 'tag_list')
  List<String> get tagList;

  /// Create a copy of ArticleDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleDtoImplCopyWith<_$ArticleDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
