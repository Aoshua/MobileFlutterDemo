# Phase 2 — Feed (Read-Only): Detailed Implementation Plan

## Context

[plan-overview.md](plan-overview.md) defines a six-phase roadmap. Phase 1 (complete) replaced the single-file scaffold with a production-grade shell: Riverpod codegen, `go_router` `StatefulShellRoute`, Material 3 dynamic color, strict lints, and feature-first folders — all with an identical 4-tab placeholder UI.

Phase 2 turns the Home placeholder into a real, network-backed article feed. After this phase you will have:

- A live, scrollable list of dev.to articles loading from `https://dev.to/api/articles`.
- Skeleton loading while the first page arrives, then real article cards.
- Infinite scroll (page 2 loads automatically as you reach the bottom).
- Pull-to-refresh that resets to page 1.
- A proper offline / error state with a retry button.
- The architecture to handle all of the above cleanly without spaghetti callbacks.

This is the densest phase because every major data-layer pattern lands here. Phases 3–6 reuse all of it.

**Concepts taught in this phase:**
- Immutable models — `freezed` + `json_serializable`
- Repository pattern — abstract interface / concrete implementation / Riverpod provider
- HTTP with `dio` — client setup, interceptors, typed exceptions
- `Result<T, AppFailure>` sealed type — explicit error handling without try/catch leaking everywhere
- Riverpod `AsyncNotifier` — paginated async state
- `AsyncValue.when` — exhaustive UI state branching
- `ListView.builder` — lazy, efficient lists
- Skeleton loading with `skeletonizer`
- Repository unit tests with `mocktail`

---

## Decisions locked for this phase

| Decision | Choice | Why |
|---|---|---|
| HTTP client | `dio` | Production apps need interceptors (logging, retry, auth headers). The `http` package is too bare. |
| DTO vs domain model | **Separate** | The DTO knows about JSON; the domain model never does. This anti-corruption layer means a backend schema change only touches one file, not your whole app. |
| Error type | `sealed class AppFailure` | Dart 3 sealed classes force you to handle every case in a `switch`. No more "forgot to handle the network error" bugs. |
| Result wrapper | `sealed class Result<T, E>` | Repositories return `Result`, never throw. Exceptions stay inside the data layer. |
| Pagination strategy | `?page=N&per_page=20` cursor in notifier state | Matches the dev.to API; teaches stateful async notifiers. |
| Skeleton library | `skeletonizer ^1.4` | Wraps your real widget tree — the skeleton has the same shape as the loaded card automatically. |
| Mock library | `mocktail ^1` | No codegen needed — define mocks with `class MockFoo extends Mock implements Foo {}`. Fast. |
| Codegen files | Committed to git | Same policy as Phase 1. |

---

## Dart & Flutter concepts — explained before you use them

### Why `freezed`?

In Dart, plain classes are mutable and have no built-in equality. `freezed` generates:
- An immutable value class (`@freezed` + `factory`).
- A `copyWith` method (returns a new instance with changed fields).
- `==` and `hashCode` based on field values (not object identity).
- `toString` for debugging.
- (Optionally) sealed unions — multiple variants of one type.

You write ~10 lines; `freezed` generates ~100 lines of correct, tested boilerplate.

#### The syntax pattern

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';  // generated file, treated as part of this library

@freezed                       // triggers the generator
class Article with _$Article { // _$Article mixin comes from the generated file
  const factory Article({     // const factory constructor
    required int id,
    required String title,
    String? coverImageUrl,    // nullable = optional
  }) = _Article;              // _Article is the generated concrete class
}
```

Four pieces must all be present or code generation will fail: `@freezed`, `with _$ClassName`, `const factory`, and `= _ClassName`.

#### What gets generated (into `article.freezed.dart`)

| Generated feature | What it gives you |
|---|---|
| Immutable fields | All fields are `final`; you cannot mutate after construction |
| `copyWith` | `article.copyWith(title: 'New')` returns a new instance with just that field changed |
| `==` and `hashCode` | Two `Article` objects with the same field values are equal |
| `toString` | `Article(id: 1, title: 'Hello', ...)` — useful in debug output |

`copyWith` is essential for Riverpod state — you never mutate state in place, you always produce a new value. Value equality means `ref.watch` can correctly detect when state actually changed.

#### DTOs get an extra layer

DTO classes combine `@freezed` with `@JsonSerializable`, requiring two `part` directives and two generated files:

```dart
part 'article_dto.freezed.dart';
part 'article_dto.g.dart';      // second generated file, from json_serializable

@freezed
class ArticleDto with _$ArticleDto {
  const factory ArticleDto({
    @JsonKey(name: 'cover_image') String? coverImage, // renames the JSON key
    ...
  }) = _ArticleDto;

  factory ArticleDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDtoFromJson(json); // implemented in the .g.dart file
}
```

`freezed` produces the `.freezed.dart` file (immutability, copyWith, equality). `json_serializable` produces the `.g.dart` file (`fromJson`/`toJson`). Both run on the same class; both `part` directives are required. The domain `Article` uses only `@freezed` — no JSON annotations, no knowledge of the network.

### Why two model files (DTO vs domain)?

The **DTO** (`article_dto.dart`) maps 1:1 to the JSON the API sends. It uses `@JsonKey` annotations to rename snake_case JSON fields to camelCase Dart fields, and `@JsonSerializable` to generate `fromJson`/`toJson`.

The **domain model** (`article.dart`) is what the rest of your app uses. It has no JSON annotations, no dependency on `json_annotation`, and its fields are named what *you* want — not what the API sends. The repository converts DTO → domain. If the API changes its field names tomorrow, you update the DTO and the conversion, nothing else.

### Why `dio` over the `http` package?

`dio` gives you **interceptors** — objects that run before every request and after every response. In this phase you add two:
1. **LoggingInterceptor** — prints every request/response/error to the debug console in development. Remove it in release mode.
2. **RetryInterceptor** — automatically retries on HTTP 5xx responses (server errors) up to N times.

The `http` package gives you none of this natively.

### What is a sealed class in Dart 3?

```dart
sealed class AppFailure {}
class NetworkFailure extends AppFailure { ... }
class ServerFailure extends AppFailure { final int statusCode; ... }
class NotFoundFailure extends AppFailure {}
class UnknownFailure extends AppFailure { final Object error; ... }
```

When you `switch` on a sealed type, the Dart compiler **enforces exhaustiveness** — if you add a new subclass and forget to handle it in a switch, your code won't compile. No more silent missed cases.

### What is `Result<T, E>`?

```dart
sealed class Result<T, E> {}
class Ok<T, E> extends Result<T, E> { final T value; }
class Err<T, E> extends Result<T, E> { final E error; }
```

Repositories return `Result<Article, AppFailure>`. You handle both cases at the call site:
```dart
switch (result) {
  case Ok(:final value): // use value
  case Err(:final error): // handle error
}
```
No try/catch leaking up through layers. No `null` values used as "something went wrong."

### What is `AsyncNotifier`?

`AsyncNotifier` is a Riverpod building block for state that is loaded asynchronously. You extend it and override `build()` — Riverpod calls `build()` to populate the initial state. You can then expose methods (like `loadNextPage()` and `refresh()`) that update the state.

The state type is always `AsyncValue<T>`, which is a sealed union:
- `AsyncLoading()` — still loading
- `AsyncData(value)` — loaded successfully
- `AsyncError(error, stackTrace)` — failed

In the widget you call `.when(data: ..., loading: ..., error: ...)` to branch on all three cases.

### What is a sentinel tile?

Instead of detecting "did the user scroll to the bottom" with a scroll listener, you put a special last tile in the `ListView.builder`. When Flutter builds that tile (meaning it's now visible), you trigger the next page load. It's simple, accurate, and idiomatic.

---

## Packages to add

Edit [pubspec.yaml](../pubspec.yaml):

```yaml
dependencies:
  # (existing)
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0
  go_router: ^14.0.0
  dynamic_color: ^1.7.0
  # Phase 2 additions:
  dio: ^5.7.0                        # HTTP client with interceptors
  freezed_annotation: ^2.4.0        # Annotations for the freezed codegen tool
  json_annotation: ^4.9.0           # Annotations for json_serializable
  skeletonizer: ^1.4.0              # Skeleton loading shimmer

dev_dependencies:
  # (existing)
  very_good_analysis: ^7.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.6.0
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.0
  # Phase 2 additions:
  freezed: ^2.5.0                   # Code generator for freezed models
  json_serializable: ^6.8.0         # Code generator for toJson/fromJson
  mocktail: ^1.0.0                  # Mock library for tests (no codegen)
  http_mock_adapter: ^0.6.0         # Dio-specific request interceptor for tests
```

Run: `flutter pub get`.

---

## Folder structure to create

```
lib/
  core/
    network/
      dio_client.dart               # Creates and configures the Dio instance
      logging_interceptor.dart      # Logs requests/responses in debug mode
      retry_interceptor.dart        # Retries on 5xx errors
      api_exception.dart            # Typed exception thrown by the data layer
    result.dart                     # sealed Result<T, E>
    failure.dart                    # sealed AppFailure variants
  features/
    feed/
      data/
        dto/
          article_dto.dart          # JSON-annotated DTO (fromJson/toJson generated)
          user_dto.dart             # User sub-object DTO
        article_api.dart            # Raw dio calls — returns DTOs or throws ApiException
        article_repository_impl.dart # Converts DTO→domain, wraps in Result
      domain/
        article.dart                # Pure domain model (no JSON annotations)
        article_repository.dart     # Abstract interface (contract only)
      presentation/
        feed_controller.dart        # AsyncNotifier — pagination state
        feed_page.dart              # Replaces placeholder; consumes controller
        widgets/
          article_card.dart         # One article row
          article_card_skeleton.dart # Skeletonized version of the card
          feed_error_view.dart      # Error + retry button
          feed_empty_view.dart      # Empty state illustration
test/
  features/
    feed/
      data/
        article_repository_impl_test.dart
      presentation/
        feed_controller_test.dart
```

---

## Implementation sequence

Order matters — each step leaves `flutter analyze` green.

---

### Step 1 — Core: `Result` and `AppFailure` sealed types

**`lib/core/result.dart`**

```dart
sealed class Result<T, E> {
  const Result();
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
```

**What you're learning:** Dart 3 sealed classes + `final class`. `sealed` means all subclasses must be in the same file — the compiler can enumerate them. `final` means no further subclassing is allowed outside this file. The type parameters `<T, E>` make this generic: `Result<Article, AppFailure>`, `Result<List<Article>, AppFailure>`, etc.

**`lib/core/failure.dart`**

```dart
sealed class AppFailure {
  const AppFailure();
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({this.message});
  final String? message;
}

final class ServerFailure extends AppFailure {
  const ServerFailure({required this.statusCode, this.message});
  final int statusCode;
  final String? message;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({required this.error});
  final Object error;
}
```

**What you're learning:** Sealed class hierarchies as typed error enumerations. The widget will `switch` on this and the compiler won't compile until all four cases are handled.

---

### Step 2 — Core network layer

**`lib/core/network/api_exception.dart`**

The data layer catches every exception at the boundary and maps it to a typed exception:

```dart
class ApiException implements Exception {
  const ApiException({required this.failure});
  final AppFailure failure;

  @override
  String toString() => 'ApiException($failure)';
}
```

**What you're learning:** An `implements Exception` class is a plain Dart class that satisfies the `Exception` type — no magic required. We use this as the single exception type that can escape the data layer, carrying a fully-mapped `AppFailure` inside it.

---

**`lib/core/network/logging_interceptor.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] → ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] ← ${response.statusCode} ${response.realUri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[HTTP] ✗ ${err.type} ${err.message}');
    }
    handler.next(err);
  }
}
```

**What you're learning:** Interceptors extend `Interceptor` and override three hooks. Always call `handler.next()` to pass the request/response/error along the chain — if you forget, the request stalls forever. `kDebugMode` is Flutter's compile-time constant for debug builds; the `if (kDebugMode)` block tree-shakes out of release builds entirely.

---

**`lib/core/network/retry_interceptor.dart`**

```dart
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 2});
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && _retriesLeft(err) > 0) {
      final retryCount = _retriesLeft(err) - 1;
      final options = err.requestOptions..extra['retries'] = retryCount;
      try {
        final response = await Dio().fetch(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  int _retriesLeft(DioException err) =>
      (err.requestOptions.extra['retries'] as int?) ?? maxRetries;
}
```

**What you're learning:** Interceptors can be `async`. The `extra` map on `RequestOptions` is a free-form `Map<String, dynamic>` you can use to pass data between interceptors on the same request — here used as a retry counter. `handler.resolve(response)` short-circuits the error chain and returns the response to the caller as if the request succeeded.

---

**`lib/core/network/dio_client.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_flutter_demo/core/env/app_env.dart';
import 'logging_interceptor.dart';
import 'retry_interceptor.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  final env = ref.watch(appEnvProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.devtoBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    LoggingInterceptor(),
    RetryInterceptor(),
  ]);
  return dio;
}
```

**What you're learning:** `@riverpod` on a function (not a class) generates a plain `Provider`. The returned `Dio` instance is shared across every class that calls `ref.watch(dioClientProvider)`. `BaseOptions` sets defaults applied to every request — you don't have to repeat them per call. `connectTimeout` is how long to wait for the TCP connection; `receiveTimeout` is how long to wait for data once connected.

Run codegen after this file: `dart run build_runner build --delete-conflicting-outputs`. It generates `lib/core/network/dio_client.g.dart`.

---

### Step 3 — Domain models

**`lib/features/feed/domain/article.dart`**

```dart
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
```

**What you're learning:** `@freezed` + `with _$Article` + `const factory` is the freezed pattern. The `part 'article.freezed.dart'` directive tells Dart that `article.freezed.dart` will be generated and should be considered part of this library — it will contain the `_$Article` mixin and `_Article` class. Notice there are **no JSON annotations here** — this class has zero awareness of the network. `String?` with a `?` is a nullable type — cover images are optional.

---

**`lib/features/feed/domain/article_repository.dart`**

```dart
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'article.dart';

abstract interface class ArticleRepository {
  Future<Result<List<Article>, AppFailure>> getArticles({
    required int page,
    int perPage = 20,
  });
}
```

**What you're learning:** `abstract interface class` (Dart 3.0+) is a class that can only be implemented, not extended. This is the **contract** — any class that `implements ArticleRepository` must provide `getArticles`. The implementation lives in the `data/` layer; the rest of the app only knows about this interface. This means you can swap implementations (real API, fake, cached) without changing a single widget.

---

### Step 4 — DTOs and JSON serialization

**`lib/features/feed/data/dto/user_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String username,
    @JsonKey(name: 'profile_image_90') required String profileImage,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
```

**What you're learning:** Two codegen annotations on one class: `@freezed` generates the immutable class boilerplate, and `@JsonKey(name: 'profile_image_90')` renames the JSON key — the API sends `profile_image_90`, your Dart field is `profileImage`. Without `@JsonKey`, the field name must match the JSON key exactly. The `factory fromJson` is implemented by the generated `_$UserDtoFromJson` function.

---

**`lib/features/feed/data/dto/article_dto.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';

part 'article_dto.freezed.dart';
part 'article_dto.g.dart';

@freezed
class ArticleDto with _$ArticleDto {
  const factory ArticleDto({
    required int id,
    required String title,
    required String description,
    required String url,
    required UserDto user,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'positive_reactions_count')
    required int positiveReactionsCount,
    @JsonKey(name: 'comments_count') required int commentsCount,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    @JsonKey(name: 'tag_list') required List<String> tagList,
  }) = _ArticleDto;

  factory ArticleDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDtoFromJson(json);
}
```

**What you're learning:** `DateTime publishedAt` — `json_serializable` knows how to parse ISO 8601 date strings (what dev.to sends) into `DateTime` automatically. `List<String> tagList` — `json_serializable` handles generic collections too. All the snake_case → camelCase renaming happens here in the DTO, so the domain model and all widgets use idiomatic Dart naming.

Run codegen after these two files: generates `article_dto.freezed.dart`, `article_dto.g.dart`, `user_dto.freezed.dart`, `user_dto.g.dart`.

---

### Step 5 — Article API (raw HTTP)

**`lib/features/feed/data/article_api.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'dto/article_dto.dart';

class ArticleApi {
  const ArticleApi({required this.dio});
  final Dio dio;

  Future<List<ArticleDto>> fetchArticles({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/articles',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data;
      if (data == null) throw const ApiException(failure: NetworkFailure());
      return data.cast<Map<String, dynamic>>().map(ArticleDto.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(failure: _mapDioError(e));
    }
  }

  AppFailure _mapDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout =>
          NetworkFailure(message: e.message),
        DioExceptionType.badResponse => switch (e.response?.statusCode) {
            404 => const NotFoundFailure(),
            _ => ServerFailure(statusCode: e.response?.statusCode ?? 0),
          },
        _ => UnknownFailure(error: e),
      };
}
```

**What you're learning:** `dio.get<List<dynamic>>()` — the type parameter tells Dio what to expect; helps readability and IDE completion. `response.data` is `dynamic` until you cast it. `.cast<Map<String, dynamic>>()` converts the untyped `List<dynamic>` to a typed list — safe here because we know the JSON shape from the dev.to API contract. The `switch` on `e.type` uses Dart 3 pattern matching with `||` to combine cases. This is the **only place** in the entire app where `DioException` is caught — everything above sees only `ApiException` with a mapped `AppFailure`.

---

### Step 6 — Repository implementation

**`lib/features/feed/data/article_repository_impl.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'package:mobile_flutter_demo/core/network/dio_client.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'article_api.dart';
import 'dto/article_dto.dart';

part 'article_repository_impl.g.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl({required this.api});
  final ArticleApi api;

  @override
  Future<Result<List<Article>, AppFailure>> getArticles({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final dtos = await api.fetchArticles(page: page, perPage: perPage);
      return Ok(dtos.map(_toArticle).toList());
    } on ApiException catch (e) {
      return Err(e.failure);
    } catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  Article _toArticle(ArticleDto dto) => Article(
        id: dto.id,
        title: dto.title,
        description: dto.description,
        url: dto.url,
        username: dto.user.username,
        userProfileImage: dto.user.profileImage,
        coverImageUrl: dto.coverImage,
        positiveReactionsCount: dto.positiveReactionsCount,
        commentsCount: dto.commentsCount,
        publishedAt: dto.publishedAt,
        tags: dto.tagList,
      );
}

@riverpod
ArticleRepository articleRepository(ArticleRepositoryRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ArticleRepositoryImpl(api: ArticleApi(dio: dio));
}
```

**What you're learning:** The provider returns `ArticleRepository` (the abstract interface), not `ArticleRepositoryImpl`. This is intentional — calling code only knows the interface. In tests you'll override `articleRepositoryProvider` with a `MockArticleRepository` that also implements the interface. The `_toArticle` method is the anti-corruption layer: DTO fields map to domain fields here, nowhere else. Phase 5 will add caching to this method — the interface contract stays unchanged.

---

### Step 7 — Feed controller (AsyncNotifier)

**`lib/features/feed/presentation/feed_controller.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';

part 'feed_controller.g.dart';

@riverpod
class FeedController extends _$FeedController {
  static const _perPage = 20;
  var _page = 1;
  var _hasMore = true;

  @override
  Future<List<Article>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(_page);
  }

  Future<void> loadNextPage() async {
    if (!_hasMore) return;
    if (state is AsyncLoading) return;

    final current = state.valueOrNull ?? [];
    state = const AsyncLoading();

    final next = _page + 1;
    final result = await _repo.getArticles(page: next, perPage: _perPage);

    switch (result) {
      case Ok(:final value):
        _page = next;
        _hasMore = value.length == _perPage;
        state = AsyncData([...current, ...value]);
      case Err():
        // Restore previous data so the existing list stays visible
        state = AsyncData(current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _page = 1;
    _hasMore = true;
    try {
      state = AsyncData(await _fetchPage(1));
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  ArticleRepository get _repo => ref.read(articleRepositoryProvider);

  Future<List<Article>> _fetchPage(int page) async {
    final result = await _repo.getArticles(page: page, perPage: _perPage);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error, // caught by AsyncNotifier.build → AsyncError
    };
  }
}
```

**What you're learning:** `AsyncNotifier.build()` is called automatically by Riverpod when the provider is first watched (or invalidated). It returns a `Future<T>` — Riverpod wraps it in `AsyncLoading` while it runs, then `AsyncData` or `AsyncError`. You can manually set `state = AsyncData(...)`, `state = AsyncLoading()`, or `state = AsyncError(...)` from any method. `state.valueOrNull` returns the current data or `null` if loading/error — used here to keep displaying the old list while appending the next page. `ref.read` (not `ref.watch`) inside a method is correct — you don't want a method call to re-subscribe to a provider.

---

### Step 8 — Article card widgets

**`lib/features/feed/presentation/widgets/article_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.coverImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.coverImageUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 8),
            Text(article.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              article.description,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(article.userProfileImage),
                  radius: 12,
                ),
                const SizedBox(width: 6),
                Text(article.username, style: theme.textTheme.labelSmall),
                const Spacer(),
                const Icon(Icons.favorite_outline, size: 14),
                const SizedBox(width: 2),
                Text(
                  '${article.positiveReactionsCount}',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(width: 10),
                const Icon(Icons.comment_outlined, size: 14),
                const SizedBox(width: 2),
                Text(
                  '${article.commentsCount}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            if (article.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: article.tags
                    .take(3)
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        labelStyle: theme.textTheme.labelSmall,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**What you're learning:** `if (condition) widget` inside a `Column`'s `children` list — a collection-if. It inserts the widget only when the condition is true; the list stays a `List<Widget>` statically. `const EdgeInsets.symmetric(...)` — `const` constructors are evaluated at compile time, so Flutter never allocates a new object on each rebuild. `Image.network` with an `errorBuilder` — if the image URL is broken or slow, show nothing instead of a red error box. `...[widget1, widget2]` — spread operator inside a list, used after `if` to conditionally insert multiple widgets.

---

**`lib/features/feed/presentation/widgets/article_card_skeleton.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'article_card.dart';

class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});

  static final _fake = Article(
    id: 0,
    title: 'Loading article title placeholder text',
    description: 'Loading description that spans two lines of text here',
    url: '',
    username: 'username',
    userProfileImage: '',
    positiveReactionsCount: 99,
    commentsCount: 9,
    publishedAt: DateTime(2024),
    tags: const ['flutter', 'dart'],
  );

  @override
  Widget build(BuildContext context) => Skeletonizer(
        child: ArticleCard(article: _fake),
      );
}
```

**What you're learning:** `skeletonizer` wraps any widget and replaces its painted content with shimmer rectangles of the **exact same shape**. You pass a real widget with fake data — the library handles the animation. This ensures your skeleton looks like your loaded card. `static final _fake` is a class-level field — created once, never rebuilt on every `build()` call.

---

**`lib/features/feed/presentation/widgets/feed_error_view.dart`**

```dart
import 'package:flutter/material.dart';

class FeedErrorView extends StatelessWidget {
  const FeedErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64),
            const SizedBox(height: 16),
            const Text('Failed to load articles'),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
```

---

**`lib/features/feed/presentation/widgets/feed_empty_view.dart`**

```dart
import 'package:flutter/material.dart';

class FeedEmptyView extends StatelessWidget {
  const FeedEmptyView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('No articles found.'),
      );
}
```

---

### Step 9 — Feed page (replaces the placeholder)

**`lib/features/feed/presentation/feed_page.dart`** (rewrite — replaces the Phase 1 placeholder)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feed_controller.dart';
import 'widgets/article_card.dart';
import 'widgets/article_card_skeleton.dart';
import 'widgets/feed_empty_view.dart';
import 'widgets/feed_error_view.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
      child: state.when(
        loading: () => const _SkeletonList(),
        error: (_, __) => FeedErrorView(
          onRetry: () => ref.invalidate(feedControllerProvider),
        ),
        data: (articles) {
          if (articles.isEmpty) return const FeedEmptyView();
          return ListView.builder(
            itemCount: articles.length + 1, // +1 for sentinel tile
            itemBuilder: (context, index) {
              if (index == articles.length) {
                // Sentinel tile — triggers next page when scrolled into view
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(feedControllerProvider.notifier).loadNextPage();
                });
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ArticleCard(article: articles[index]);
            },
          );
        },
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => const ArticleCardSkeleton(),
      );
}
```

**What you're learning:** `ConsumerWidget` is the Riverpod equivalent of `StatelessWidget` — it adds a `WidgetRef ref` parameter to `build`. `ref.watch(feedControllerProvider)` subscribes this widget to the controller's `AsyncValue<List<Article>>` state and rebuilds on every change. `.when(loading:, error:, data:)` exhaustively handles all three `AsyncValue` states — the Dart compiler errors if you omit one. `ListView.builder` builds items lazily — only those visible on screen (plus a small buffer) are created; critical for performance with long lists. `addPostFrameCallback` defers `loadNextPage()` to after the current frame — you cannot mutate state during a widget's `build` call. `ref.invalidate(provider)` disposes the provider and re-runs `build()` from scratch — the cleanest "retry" mechanism.

---

### Step 10 — Run codegen

After all the `@freezed`, `@JsonSerializable`, and `@riverpod` annotations are in place:

```
dart run build_runner build --delete-conflicting-outputs
```

Expected generated files (all committed to git):
- `lib/core/network/dio_client.g.dart`
- `lib/features/feed/data/dto/article_dto.freezed.dart`
- `lib/features/feed/data/dto/article_dto.g.dart`
- `lib/features/feed/data/dto/user_dto.freezed.dart`
- `lib/features/feed/data/dto/user_dto.g.dart`
- `lib/features/feed/data/article_repository_impl.g.dart`
- `lib/features/feed/domain/article.freezed.dart`
- `lib/features/feed/presentation/feed_controller.g.dart`

Run `flutter analyze` after — zero issues expected.

---

### Step 11 — Tests

#### Repository unit test

**`test/features/feed/data/article_repository_impl_test.dart`**

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_api.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ArticleRepositoryImpl repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://dev.to/api'));
    adapter = DioAdapter(dio: dio);
    repo = ArticleRepositoryImpl(api: ArticleApi(dio: dio));
  });

  group('getArticles', () {
    test('returns Ok with parsed articles on 200', () async {
      adapter.onGet(
        '/articles',
        (server) => server.reply(200, [
          {
            'id': 1,
            'title': 'Test',
            'description': 'Desc',
            'url': 'https://dev.to/test',
            'user': {'username': 'alice', 'profile_image_90': 'https://img'},
            'cover_image': null,
            'positive_reactions_count': 5,
            'comments_count': 1,
            'published_at': '2024-01-01T00:00:00Z',
            'tag_list': ['flutter'],
          }
        ]),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect(result, isA<Ok<List, AppFailure>>());
      final articles = (result as Ok).value as List;
      expect(articles.length, 1);
      expect(articles.first.title, 'Test');
    });

    test('returns Err(NetworkFailure) on connection timeout', () async {
      adapter.onGet(
        '/articles',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect(result, isA<Err<List, AppFailure>>());
      expect((result as Err).error, isA<NetworkFailure>());
    });

    test('returns Err(NotFoundFailure) on 404', () async {
      adapter.onGet(
        '/articles',
        (server) => server.reply(404, {'error': 'not found'}),
        queryParameters: {'page': 1, 'per_page': 20},
      );

      final result = await repo.getArticles(page: 1);

      expect((result as Err).error, isA<NotFoundFailure>());
    });
  });
}
```

**What you're learning:** `DioAdapter` from `http_mock_adapter` intercepts outgoing `Dio` requests at the transport layer — no real HTTP requests fire during tests. `server.reply(statusCode, body)` defines the canned response. `server.throws(...)` simulates a transport-level exception. `setUp(() {...})` runs before every `test` — each test gets a fresh `Dio` + `DioAdapter` so tests are fully isolated from each other.

---

#### Feed controller test

**`test/features/feed/presentation/feed_controller_test.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/feed/data/article_repository_impl.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article_repository.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/feed_controller.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockArticleRepository();
    container = ProviderContainer(
      overrides: [
        articleRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
  });

  test('transitions AsyncLoading → AsyncData on success', () async {
    when(
      () => mockRepo.getArticles(page: 1, perPage: any(named: 'perPage')),
    ).thenAnswer((_) async => Ok(_fakeArticles(3)));

    expect(
      container.read(feedControllerProvider),
      const AsyncLoading<List<Article>>(),
    );

    await container.read(feedControllerProvider.future);

    expect(
      container.read(feedControllerProvider),
      isA<AsyncData<List<Article>>>(),
    );
  });

  test('transitions AsyncLoading → AsyncError on failure', () async {
    when(
      () => mockRepo.getArticles(page: 1, perPage: any(named: 'perPage')),
    ).thenAnswer((_) async => Err(const NetworkFailure()));

    await expectLater(
      container.read(feedControllerProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    expect(
      container.read(feedControllerProvider),
      isA<AsyncError<List<Article>>>(),
    );
  });
}

List<Article> _fakeArticles(int count) => List.generate(
      count,
      (i) => Article(
        id: i,
        title: 'Article $i',
        description: 'Desc $i',
        url: 'https://dev.to/$i',
        username: 'user',
        userProfileImage: 'https://img',
        positiveReactionsCount: 0,
        commentsCount: 0,
        publishedAt: DateTime(2024),
        tags: const [],
      ),
    );
```

**What you're learning:** `ProviderContainer` is the non-widget Riverpod container — used in pure Dart tests without Flutter's widget tree. `overrides: [provider.overrideWithValue(mock)]` replaces the real provider with your mock for the lifetime of this container. `addTearDown(container.dispose)` runs after each test — prevents provider leaks. `when(() => mock.method(...)).thenAnswer(...)` is the mocktail pattern for configuring return values. `any(named: 'perPage')` matches any value for the named argument — useful when you don't care about that argument's exact value in a particular test.

---

## Critical files

| File | Action |
|---|---|
| [pubspec.yaml](../pubspec.yaml) | Add `dio`, `freezed_annotation`, `json_annotation`, `skeletonizer`; add dev `freezed`, `json_serializable`, `mocktail`, `http_mock_adapter`. |
| `lib/core/result.dart` | New — `sealed class Result<T, E>` with `Ok` and `Err`. |
| `lib/core/failure.dart` | New — `sealed class AppFailure` with `NetworkFailure`, `ServerFailure`, `NotFoundFailure`, `UnknownFailure`. |
| `lib/core/network/api_exception.dart` | New — single exception type carrying an `AppFailure`. |
| `lib/core/network/logging_interceptor.dart` | New — debug-only request/response logger. |
| `lib/core/network/retry_interceptor.dart` | New — retries 5xx responses up to 2 times. |
| `lib/core/network/dio_client.dart` | New — `@riverpod` provider returning a configured `Dio`. |
| `lib/features/feed/data/dto/user_dto.dart` | New — `@freezed` user DTO with `@JsonKey` rename. |
| `lib/features/feed/data/dto/article_dto.dart` | New — `@freezed` article DTO with multiple `@JsonKey` renames. |
| `lib/features/feed/data/article_api.dart` | New — raw `Dio` calls, returns DTOs, throws `ApiException`. |
| `lib/features/feed/data/article_repository_impl.dart` | New — implements `ArticleRepository`, converts DTO→domain, wraps in `Result`. |
| `lib/features/feed/domain/article.dart` | New — `@freezed` domain model, no JSON annotations. |
| `lib/features/feed/domain/article_repository.dart` | New — `abstract interface class ArticleRepository`. |
| `lib/features/feed/presentation/feed_controller.dart` | New — `@riverpod class FeedController extends _$FeedController`, paginates. |
| `lib/features/feed/presentation/feed_page.dart` | **Rewrite** — replaces placeholder with real `ListView.builder` + `RefreshIndicator`. |
| `lib/features/feed/presentation/widgets/article_card.dart` | New — article row widget. |
| `lib/features/feed/presentation/widgets/article_card_skeleton.dart` | New — `Skeletonizer`-wrapped card. |
| `lib/features/feed/presentation/widgets/feed_error_view.dart` | New — error + retry button. |
| `lib/features/feed/presentation/widgets/feed_empty_view.dart` | New — empty state. |
| `test/features/feed/data/article_repository_impl_test.dart` | New — `DioAdapter` tests for 200 / 404 / timeout. |
| `test/features/feed/presentation/feed_controller_test.dart` | New — `ProviderContainer` + mocktail controller tests. |

---

## Verification

### Automated
1. `flutter pub get` — clean exit.
2. `dart run build_runner build --delete-conflicting-outputs` — all `.freezed.dart` and `.g.dart` files generated, no conflicts.
3. `flutter analyze` — zero issues under `very_good_analysis`.
4. `flutter test` — all tests pass (repository + controller + existing router test).

### Manual (Android emulator or device)
5. Cold start → ~6 skeleton cards shimmer → real articles appear.
6. Scroll to the bottom of the list → progress spinner → page 2 articles append below.
7. Pull down from the top → `RefreshIndicator` spinner → list resets to page 1.
8. Enable airplane mode → force-close app → reopen → error view with "Retry" button shown.
9. Tap "Retry" with airplane mode off → articles load successfully.
10. Open DevTools: **Performance** tab → record a fast scroll → confirm frames stay at or near 60fps. This validates `ListView.builder` lazy rendering.

---

## Out of scope (do not pull in)

- Tapping an article card → navigation to detail → Phase 3.
- `cached_network_image` for cover images → Phase 3 (use `Image.network` with `errorBuilder` for now).
- Search / tags → Phase 4.
- Bookmarks, offline persistence → Phase 5.
- `ProviderObserver` for global logging → optional refinement.
- Golden tests (screenshot comparisons) → Phase 3, when the article card design is stable.
