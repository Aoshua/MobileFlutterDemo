// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Article {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get userProfileImage => throw _privateConstructorUsedError;
  int get positiveReactionsCount => throw _privateConstructorUsedError;
  int get commentsCount => throw _privateConstructorUsedError;
  DateTime get publishedAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get coverImageUrl => throw _privateConstructorUsedError;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleCopyWith<Article> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleCopyWith<$Res> {
  factory $ArticleCopyWith(Article value, $Res Function(Article) then) =
      _$ArticleCopyWithImpl<$Res, Article>;
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String url,
    String username,
    String userProfileImage,
    int positiveReactionsCount,
    int commentsCount,
    DateTime publishedAt,
    List<String> tags,
    String? coverImageUrl,
  });
}

/// @nodoc
class _$ArticleCopyWithImpl<$Res, $Val extends Article>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? username = null,
    Object? userProfileImage = null,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? publishedAt = null,
    Object? tags = null,
    Object? coverImageUrl = freezed,
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
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            userProfileImage: null == userProfileImage
                ? _value.userProfileImage
                : userProfileImage // ignore: cast_nullable_to_non_nullable
                      as String,
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
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleImplCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$$ArticleImplCopyWith(
    _$ArticleImpl value,
    $Res Function(_$ArticleImpl) then,
  ) = __$$ArticleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String description,
    String url,
    String username,
    String userProfileImage,
    int positiveReactionsCount,
    int commentsCount,
    DateTime publishedAt,
    List<String> tags,
    String? coverImageUrl,
  });
}

/// @nodoc
class __$$ArticleImplCopyWithImpl<$Res>
    extends _$ArticleCopyWithImpl<$Res, _$ArticleImpl>
    implements _$$ArticleImplCopyWith<$Res> {
  __$$ArticleImplCopyWithImpl(
    _$ArticleImpl _value,
    $Res Function(_$ArticleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? username = null,
    Object? userProfileImage = null,
    Object? positiveReactionsCount = null,
    Object? commentsCount = null,
    Object? publishedAt = null,
    Object? tags = null,
    Object? coverImageUrl = freezed,
  }) {
    return _then(
      _$ArticleImpl(
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
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        userProfileImage: null == userProfileImage
            ? _value.userProfileImage
            : userProfileImage // ignore: cast_nullable_to_non_nullable
                  as String,
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
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ArticleImpl implements _Article {
  const _$ArticleImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.username,
    required this.userProfileImage,
    required this.positiveReactionsCount,
    required this.commentsCount,
    required this.publishedAt,
    required final List<String> tags,
    this.coverImageUrl,
  }) : _tags = tags;

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String url;
  @override
  final String username;
  @override
  final String userProfileImage;
  @override
  final int positiveReactionsCount;
  @override
  final int commentsCount;
  @override
  final DateTime publishedAt;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? coverImageUrl;

  @override
  String toString() {
    return 'Article(id: $id, title: $title, description: $description, url: $url, username: $username, userProfileImage: $userProfileImage, positiveReactionsCount: $positiveReactionsCount, commentsCount: $commentsCount, publishedAt: $publishedAt, tags: $tags, coverImageUrl: $coverImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            (identical(other.positiveReactionsCount, positiveReactionsCount) ||
                other.positiveReactionsCount == positiveReactionsCount) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    url,
    username,
    userProfileImage,
    positiveReactionsCount,
    commentsCount,
    publishedAt,
    const DeepCollectionEquality().hash(_tags),
    coverImageUrl,
  );

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      __$$ArticleImplCopyWithImpl<_$ArticleImpl>(this, _$identity);
}

abstract class _Article implements Article {
  const factory _Article({
    required final int id,
    required final String title,
    required final String description,
    required final String url,
    required final String username,
    required final String userProfileImage,
    required final int positiveReactionsCount,
    required final int commentsCount,
    required final DateTime publishedAt,
    required final List<String> tags,
    final String? coverImageUrl,
  }) = _$ArticleImpl;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get url;
  @override
  String get username;
  @override
  String get userProfileImage;
  @override
  int get positiveReactionsCount;
  @override
  int get commentsCount;
  @override
  DateTime get publishedAt;
  @override
  List<String> get tags;
  @override
  String? get coverImageUrl;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
