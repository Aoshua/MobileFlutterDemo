# Phase 3 — Article Detail

## Context

Phases 1 and 2 gave you a production-grade app shell and a working, paginated feed. Phase 3 adds the most visible feature: tapping an article card opens a full-screen detail page. Along the way you'll learn how navigation works across multiple screens, how to animate between them, how to render rich markdown, and several Dart/Flutter patterns that didn't appear in the feed.

**What changes in Phase 3:**

| Area | What you'll do |
|---|---|
| Data | New `article` feature with its own DTO, API, and repository — mirrors Phase 2's pattern exactly |
| Domain | `ArticleDetail` model (adds `bodyMarkdown`) and its repository interface |
| Presentation | `ArticleDetailController` (a *family* provider), `ArticleDetailPage`, and 4 small widgets |
| Router | Add a top-level `/article/:id` route *outside* the bottom-nav shell |
| Feed | Make `ArticleCard` tappable; add `Hero` animation and `CachedNetworkImage` |
| Android | Add an intent filter for `mobileflutterdemo://` deep links |
| Tests | Controller unit test, repository unit test, golden test for `ArticleHeader` |

**Expected time:** 3–4 days at a relaxed pace.

---

## Concepts You'll Learn

Before diving in, here's a preview of what each new idea teaches you. You'll encounter each one in context during the steps below.

### Riverpod `family` providers
A regular provider (`@riverpod`) is a singleton — one instance for the whole app. A *family* provider is parameterised: `articleDetailControllerProvider(42)` and `articleDetailControllerProvider(99)` are two separate cached instances. Riverpod creates the family automatically when your `build()` method has a parameter.

### Root vs. branch navigators
`StatefulShellRoute` maintains a *separate navigator per tab* so each tab has its own navigation stack. The bottom nav bar is always visible within that shell. But the detail page should appear *above* the shell with no bottom nav. You achieve this by routing the `/article/:id` page through the *root* navigator — the one that owns the shell itself.

### Hero animations
`Hero` is Flutter's built-in shared-element transition. You wrap the same logical widget in a `Hero(tag: ...)` on both screens. During the navigation transition, Flutter finds the matching tags and smoothly morphs one into the other. The tag must be a stable, unique string — `'article-cover-${article.id}'` works perfectly.

### `CachedNetworkImage`
`Image.network` re-downloads every time. `CachedNetworkImage` stores the decoded image on disk (via `flutter_cache_manager`) and in memory. You also control `memCacheWidth` — the size at which the decoded image is stored in GPU memory — to prevent wasting GPU texture memory on images larger than their display size.

### `flutter_markdown_plus`
The dev.to API returns article bodies as raw Markdown. `flutter_markdown_plus` parses and renders it with a `MarkdownBody` widget. You can customise the rendering with a `MarkdownStyleSheet` (colours, code block backgrounds, etc.) and intercept link taps with `onTapLink` to open them in the system browser.

### `RepaintBoundary`
During scroll, Flutter repaints layers that moved. A `RepaintBoundary` tells Flutter "this subtree's paint output won't change during scroll — cache it as a compositing layer." Wrapping a large, complex `MarkdownBody` in one prevents unnecessary repaints as the user scrolls through the article.

### `share_plus`
The `Share.share(url)` call hands control to the OS and displays the system share sheet (AirDrop, WhatsApp, copy-to-clipboard, etc.). There is no Flutter UI to build — you just call the method.

### `url_launcher` + Android `<queries>`
`launchUrl(uri, mode: LaunchMode.externalApplication)` opens a URL in the device browser. On Android 11+ you must declare which URL schemes your app *queries for* in `AndroidManifest.xml`; otherwise `canLaunchUrl` always returns `false`.

### Deep links
A deep link is a URL that opens a specific screen inside your app. On Android, you declare an `<intent-filter>` for your custom URI scheme. Flutter's router delegate receives the incoming URI and matches it against your routes — no extra code required.

---

## Folder Structure to Create

```
lib/features/article/
  data/
    dto/
      article_detail_dto.dart        ← new DTO (reuses UserDto from feed)
      article_detail_dto.freezed.dart  ← generated (run build_runner)
      article_detail_dto.g.dart        ← generated
    article_detail_api.dart          ← raw Dio call
    article_detail_repository_impl.dart  ← DTO → domain + Result wrapping
    article_detail_repository_impl.g.dart  ← generated
  domain/
    article_detail.dart              ← @freezed domain model
    article_detail.freezed.dart        ← generated
    article_detail_repository.dart   ← abstract interface
  presentation/
    article_detail_controller.dart   ← @riverpod family AsyncNotifier
    article_detail_controller.g.dart   ← generated
    article_detail_page.dart         ← ConsumerWidget, the full screen
    widgets/
      article_header.dart            ← Hero + CachedNetworkImage cover
      reading_time_chip.dart         ← small Chip widget
      article_markdown_body.dart     ← MarkdownBody wrapper
      share_button.dart              ← IconButton → Share.share()

test/features/article/
  data/
    article_detail_repository_impl_test.dart
  presentation/
    article_detail_controller_test.dart
    goldens/
      article_header.png             ← generated on first run
```

Plus changes to existing files:
- `pubspec.yaml` — 4 new dependencies
- `lib/app/router.dart` — root navigator key + new route
- `lib/features/feed/presentation/widgets/article_card.dart` — tap + Hero + CachedNetworkImage
- `android/app/src/main/AndroidManifest.xml` — deep link intent filter

---

## Step 0: Update pubspec.yaml

Open `pubspec.yaml` and add to `dependencies:`:

```yaml
dependencies:
  # ... existing deps ...
  flutter_markdown_plus: ^1.0.0
  cached_network_image: ^3.4.0
  share_plus: ^10.0.0
  url_launcher: ^6.3.0
```

Then run:

```
flutter pub get
```

**Why these four?**
- `flutter_markdown_plus` — renders the `body_markdown` field the API returns.
- `cached_network_image` — replaces `Image.network` everywhere; disk + memory caching.
- `share_plus` — wraps the OS share sheet in a single method call.
- `url_launcher` — opens links from inside the markdown in the system browser.

---

## Step 1: Data Layer

The pattern here is identical to Phase 2's feed data layer. If you feel comfortable with that, this step will feel like repetition — which is the point. Repetition with new types builds fluency.

### 1a. The DTO — `lib/features/article/data/dto/article_detail_dto.dart`

A DTO (Data Transfer Object) maps the raw JSON the API sends into typed Dart fields. The `@JsonKey(name: ...)` annotation bridges snake_case JSON keys to camelCase Dart names.

Notice we **reuse `UserDto`** from Phase 2 rather than duplicating it — the user object has the same shape in both the list and detail endpoints.

```dart
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
    @JsonKey(name: 'positive_reactions_count') required int positiveReactionsCount,
    @JsonKey(name: 'comments_count') required int commentsCount,
    @JsonKey(name: 'reading_time_minutes') required int readingTimeMinutes,
    @JsonKey(name: 'cover_image') String? coverImage,
    required UserDto user,
  }) = _ArticleDetailDto;

  factory ArticleDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDetailDtoFromJson(json);
}
```

**Key difference from `ArticleDto`:** This DTO adds `bodyMarkdown` and `readingTimeMinutes` — fields that the list endpoint omits but the detail endpoint includes. The API is intentionally stingy with the list to keep payload sizes small.

After creating this file, run codegen (keep it running in a separate terminal throughout this phase):

```
dart run build_runner watch --delete-conflicting-outputs
```

This generates `article_detail_dto.freezed.dart` and `article_detail_dto.g.dart`. You do not edit generated files.

### 1b. The API — `lib/features/article/data/article_detail_api.dart`

This class makes the raw HTTP call. The dev.to endpoint is `GET /articles/{id}` and returns a single JSON object (not an array).

```dart
import 'package:dio/dio.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'dto/article_detail_dto.dart';

class ArticleDetailApi {
  const ArticleDetailApi({required this.dio});
  final Dio dio;

  Future<ArticleDetailDto> fetchArticle({required int id}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/articles/$id');
      final data = response.data;
      if (data == null) throw const ApiException(failure: NetworkFailure());
      return ArticleDetailDto.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(failure: _mapDioError(e));
    }
  }

  AppFailure _mapDioError(DioException e) => switch (e.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout => NetworkFailure(message: e.message),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
      404 => const NotFoundFailure(),
      _ => ServerFailure(statusCode: e.response?.statusCode ?? 0),
    },
    _ => UnknownFailure(error: e),
  };
}
```

**Comparison with `ArticleApi`:** The only structural differences are:
1. `get<Map<String, dynamic>>` instead of `get<List<dynamic>>` — the detail endpoint returns an object, not an array.
2. `dio.get('/articles/$id')` uses string interpolation for the path parameter instead of query parameters.

Everything else — error mapping, exception re-throwing — is identical. You will notice yourself reaching for this pattern every time you add a new API endpoint.

### 1c. The Repository — `lib/features/article/data/article_detail_repository_impl.dart`

The repository sits between the API and the rest of the app. Its job is:
1. Catch `ApiException` and convert it to `Result<T, AppFailure>` (so nothing above ever deals with exceptions).
2. Convert the DTO into the domain model (the anti-corruption layer).
3. Expose a Riverpod provider so the controller can access it.

```dart
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/network/api_exception.dart';
import 'package:mobile_flutter_demo/core/network/dio_client.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'article_detail_api.dart';
import 'dto/article_detail_dto.dart';

part 'article_detail_repository_impl.g.dart';

class ArticleDetailRepositoryImpl implements ArticleDetailRepository {
  const ArticleDetailRepositoryImpl({required this.api});
  final ArticleDetailApi api;

  @override
  Future<Result<ArticleDetail, AppFailure>> getArticleDetail({
    required int id,
  }) async {
    try {
      final dto = await api.fetchArticle(id: id);
      return Ok(_toArticleDetail(dto));
    } on ApiException catch (e) {
      return Err(e.failure);
    } catch (e) {
      return Err(UnknownFailure(error: e));
    }
  }

  ArticleDetail _toArticleDetail(ArticleDetailDto dto) => ArticleDetail(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    bodyMarkdown: dto.bodyMarkdown,
    url: dto.url,
    username: dto.user.username,
    userProfileImage: dto.user.profileImage,
    coverImageUrl: dto.coverImage,
    positiveReactionsCount: dto.positiveReactionsCount,
    commentsCount: dto.commentsCount,
    readingTimeMinutes: dto.readingTimeMinutes,
    publishedAt: dto.publishedAt,
    tags: dto.tagList,
  );
}

@riverpod
ArticleDetailRepository articleDetailRepository(
  ArticleDetailRepositoryRef ref,
) {
  final dio = ref.watch(dioClientProvider);
  return ArticleDetailRepositoryImpl(api: ArticleDetailApi(dio: dio));
}
```

The `_toArticleDetail` method is the anti-corruption layer. `ArticleDetail` (domain model) never imports anything from `data/` — the mapping is always one-way, from data to domain.

---

## Step 2: Domain Layer

### 2a. The domain model — `lib/features/article/domain/article_detail.dart`

The domain model is pure Dart — no JSON annotations, no imports from `data/`. It's what the rest of the app sees and depends on.

```dart
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
    String? coverImageUrl,
    required int positiveReactionsCount,
    required int commentsCount,
    required int readingTimeMinutes,
    required DateTime publishedAt,
    required List<String> tags,
  }) = _ArticleDetail;
}
```

**Why a separate domain model instead of reusing `Article`?** `Article` (from Phase 2) deliberately omits `bodyMarkdown` — it's not returned by the list endpoint. Adding it to `Article` would make the field always-null from the feed, which is misleading. Separate models for separate concerns keeps both models honest.

### 2b. The repository interface — `lib/features/article/domain/article_detail_repository.dart`

```dart
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'article_detail.dart';

abstract interface class ArticleDetailRepository {
  Future<Result<ArticleDetail, AppFailure>> getArticleDetail({required int id});
}
```

The `abstract interface class` keyword (Dart 3) signals "this is a pure contract, not for subclassing with shared behaviour." Tests will provide a `MockArticleDetailRepository` that implements this interface.

---

## Step 3: Presentation Layer

### 3a. The controller — `lib/features/article/presentation/article_detail_controller.dart`

This is the first *family* provider you've written. Study the `build(int id)` signature carefully — that `int id` parameter is what makes it a family.

```dart
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_repository_impl.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_detail_controller.g.dart';

@riverpod
class ArticleDetailController extends _$ArticleDetailController {
  @override
  Future<ArticleDetail> build(int id) async {
    final result = await ref
        .read(articleDetailRepositoryProvider)
        .getArticleDetail(id: id);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw error,
    };
  }
}
```

**How Riverpod codegen creates a family:** When `build` has parameters, `riverpod_generator` generates `articleDetailControllerProvider` as a *family*. You call it as `articleDetailControllerProvider(42)` — the `42` is cached automatically. Two widgets watching `articleDetailControllerProvider(42)` share the same instance; a widget watching `articleDetailControllerProvider(99)` gets a different one.

**Why throw instead of returning Err?** The `AsyncNotifier.build` return value becomes `AsyncData`. Throwing makes it become `AsyncError`. Since `AsyncValue.when(error: ...)` handles `AsyncError`, throwing is the idiomatic way to surface errors from `build`.

**autoDispose:** The `@riverpod` annotation generates an `autoDispose` provider by default. When the detail page is popped off the navigation stack, Riverpod disposes the controller automatically. The next time someone opens the same article, a fresh network request is made. This is the correct behaviour — you don't want stale article data cached forever.

**Retry:** From the UI, retry is `ref.invalidate(articleDetailControllerProvider(id))`. Invalidation disposes the provider and re-runs `build` from scratch.

### 3b. Widgets

Create these four small widgets before the page. Small, focused widgets are easier to test and reason about than one large page widget.

#### `lib/features/article/presentation/widgets/article_header.dart`

This widget is the Hero source on the detail page — the cover image that flies in from the card.

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleHeader extends StatelessWidget {
  const ArticleHeader({
    super.key,
    required this.coverImageUrl,
    required this.articleId,
  });

  final String coverImageUrl;
  final int articleId;

  @override
  Widget build(BuildContext context) {
    final pixelWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .toInt();

    return Hero(
      tag: 'article-cover-$articleId',
      child: CachedNetworkImage(
        imageUrl: coverImageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: pixelWidth,
        placeholder: (_, __) => const ColoredBox(color: Colors.black12),
        errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black12),
      ),
    );
  }
}
```

**`memCacheWidth` explained:** `CachedNetworkImage` decodes the image and stores the decoded bitmap in a GPU texture. A 1200px-wide image displayed in a 400-logical-pixel widget on a 3× screen needs to be 1200 physical pixels — but not wider. Passing `memCacheWidth: pixelWidth` tells the cache "decode at exactly this width." Without it, a 2000px image is decoded at full resolution, wasting GPU memory.

**`MediaQuery.sizeOf(context)` vs `MediaQuery.of(context).size`:** The `.sizeOf` and `.devicePixelRatioOf` static methods subscribe the widget only to the specific field they read. `MediaQuery.of(context)` subscribes to the entire `MediaQueryData`, causing rebuilds on keyboard open/close, system font changes, etc.

**Hero tag must match exactly.** The tag `'article-cover-$articleId'` must be identical in both `ArticleCard` (the source) and `ArticleHeader` (the destination). A mismatch causes the Hero to disappear; a duplicate tag (two cards on screen with the same article) causes a crash. The article ID ensures uniqueness.

#### `lib/features/article/presentation/widgets/reading_time_chip.dart`

```dart
import 'package:flutter/material.dart';

class ReadingTimeChip extends StatelessWidget {
  const ReadingTimeChip({super.key, required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.timer_outlined, size: 16),
      label: Text('$minutes min read'),
      visualDensity: VisualDensity.compact,
    );
  }
}
```

This widget is intentionally trivial. It exists because "reading time" is a distinct UI concept that could be restyled, conditionally shown, or reused on the feed card later. Extracting it avoids an inline string-format expression buried in a larger widget.

#### `lib/features/article/presentation/widgets/article_markdown_body.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class ArticleMarkdownBody extends StatelessWidget {
  const ArticleMarkdownBody({super.key, required this.markdown});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return md.MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: md.MarkdownStyleSheet.fromTheme(theme).copyWith(
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        code: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri == null) return;
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
```

**Why `import ... as md`?** `flutter_markdown_plus` exports a class named `MarkdownBody`. If you used a bare import, any local widget named `MarkdownBody` in scope would conflict. The `as md` prefix sidesteps that entirely and makes it obvious which `MarkdownBody` is from the package.

**`selectable: true`** lets the user long-press to copy text — a simple accessibility win.

**`MarkdownStyleSheet.fromTheme(theme).copyWith(...)`** inherits all colours and typography from your Material 3 theme, then overrides just the code block styles. This respects light/dark mode automatically.

**`canLaunchUrl` before `launchUrl`:** Always check before launching. On Android 11+ this requires the `<queries>` block in `AndroidManifest.xml` (added in Step 6). Without it, `canLaunchUrl` returns `false` even for valid https:// URLs.

#### `lib/features/article/presentation/widgets/share_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Share article',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.share_outlined),
        tooltip: 'Share',
        onPressed: () => Share.share(url),
      ),
    );
  }
}
```

**`Semantics`:** TalkBack (Android) and VoiceOver (iOS) use the semantic tree to describe the UI to users who can't see the screen. `IconButton` announces itself as a button but its icon doesn't have a meaningful label for screen readers. The `Semantics` wrapper adds an explicit `label: 'Share article'`.

**`Share.share(url)`** is the entire integration. The OS handles the sheet, the apps, the animation. You get this for free.

### 3c. The page — `lib/features/article/presentation/article_detail_page.dart`

This page uses `CustomScrollView` with slivers, which is the standard way to combine a collapsing app bar with a scrollable body.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter_demo/features/article/presentation/article_detail_controller.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/article_header.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/article_markdown_body.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/reading_time_chip.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/share_button.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({super.key, required this.articleId});
  final int articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(articleDetailControllerProvider(articleId));

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load article'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(articleDetailControllerProvider(articleId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (article) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: article.coverImageUrl != null ? 240 : 0,
              pinned: true,
              actions: [ShareButton(url: article.url)],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                background: article.coverImageUrl != null
                    ? ArticleHeader(
                        coverImageUrl: article.coverImageUrl!,
                        articleId: article.id,
                      )
                    : null,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReadingTimeChip(minutes: article.readingTimeMinutes),
                    const SizedBox(height: 16),
                    RepaintBoundary(
                      child: ArticleMarkdownBody(markdown: article.bodyMarkdown),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**`CustomScrollView` + slivers:** A regular `Column` can't mix a collapsing app bar with a scrollable body. Slivers solve this. `SliverAppBar` handles the collapsing header; `SliverToBoxAdapter` wraps any non-sliver widget to make it participate in the sliver scroll. Everything inside `CustomScrollView` scrolls as one unit.

**`SliverAppBar` with `pinned: true`:** The app bar shrinks as you scroll down, but never disappears entirely — the title and back button remain accessible. Without `pinned: true`, the app bar would scroll off-screen.

**`expandedHeight: article.coverImageUrl != null ? 240 : 0`:** Articles without cover images get a compact app bar (height 0 expanded = standard toolbar only). Articles with covers get a tall hero section.

**`RepaintBoundary` around `ArticleMarkdownBody`:** The markdown widget produces a complex widget tree. During scroll, Flutter repaints layers that have moved. Wrapping the markdown in `RepaintBoundary` promotes it to its own compositing layer, which Flutter can scroll by translating the layer rather than repainting it. This is the right fix for complex, static content in a scroll view.

---

## Step 4: Router Changes

Open `lib/app/router.dart`. You will make two additions:
1. A `GlobalKey<NavigatorState>` for the root navigator.
2. A new top-level `/article/:id` route before the `StatefulShellRoute`.

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter_demo/core/widgets/app_scaffold.dart';
import 'package:mobile_flutter_demo/features/activity/presentation/activity_page.dart';
import 'package:mobile_flutter_demo/features/article/presentation/article_detail_page.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/feed_page.dart';
import 'package:mobile_flutter_demo/features/profile/presentation/profile_page.dart';
import 'package:mobile_flutter_demo/features/search/presentation/search_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

// A GlobalKey gives you a stable reference to NavigatorState across rebuilds.
// 'root' is just a debug label — it appears in flutter logs, not the UI.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    routes: [
      // This route lives OUTSIDE the StatefulShellRoute.
      // parentNavigatorKey: _rootNavigatorKey means go_router pushes this
      // onto the root navigator, so the bottom nav bar is hidden.
      GoRoute(
        path: '/article/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ArticleDetailPage(articleId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ActivityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
```

**Why `parentNavigatorKey: _rootNavigatorKey`?** By default, go_router pushes routes onto the nearest ancestor navigator. Inside a `StatefulShellRoute`, that nearest ancestor is the *branch* navigator — which keeps the bottom nav bar visible. Setting `parentNavigatorKey: _rootNavigatorKey` explicitly tells go_router "push this route on the root navigator instead." The result: the detail page covers the entire screen, bottom nav and all.

**`state.pathParameters['id']!`:** go_router parses `:id` from the URL path and makes it available in `state.pathParameters`. The `!` is safe here because go_router only navigates to this route when the path matches, guaranteeing `'id'` is present. `int.parse` is also safe — article IDs from dev.to are always valid integers.

**Route ordering matters:** The `/article/:id` route must appear *before* `StatefulShellRoute` in the routes list. go_router evaluates routes in order and the first match wins.

After editing, run build_runner again if it isn't already watching. The `router.g.dart` will be regenerated.

---

## Step 5: Update ArticleCard

Open `lib/features/feed/presentation/widgets/article_card.dart` and rewrite it:

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // clipBehavior: Clip.antiAlias keeps the InkWell ripple inside card corners.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/article/${article.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.coverImageUrl != null)
                Hero(
                  tag: 'article-cover-${article.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: article.coverImageUrl!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      memCacheWidth: (MediaQuery.sizeOf(context).width *
                              MediaQuery.devicePixelRatioOf(context))
                          .toInt(),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
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
                    backgroundImage: CachedNetworkImageProvider(
                      article.userProfileImage,
                    ),
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
      ),
    );
  }
}
```

**Changes from Phase 2:**

| What changed | Why |
|---|---|
| `Card` gets `clipBehavior: Clip.antiAlias` | Keeps the `InkWell` ink ripple clipped to rounded card corners |
| Wrapped content in `InkWell` | Material ripple tap feedback; `onTap` navigates to detail |
| `context.push('/article/${article.id}')` | go_router extension method on `BuildContext`. Pushes the route onto the navigator stack. |
| `Image.network` → `Hero` + `CachedNetworkImage` | Enables Hero animation; adds disk/memory caching |
| `NetworkImage(...)` → `CachedNetworkImageProvider(...)` | Same caching benefit for the avatar |

**`context.push` vs `context.go`:** `push` adds the route to the navigator stack (back button works). `go` replaces the current location (back button goes to the previous route in history, not the feed). For a detail page, always use `push`.

---

## Step 6: Android Deep Linking

Open `android/app/src/main/AndroidManifest.xml`.

**Change 1:** Add `<queries>` for `url_launcher`. This goes directly inside `<manifest>`, before `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Required for url_launcher on Android 11+ -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="http" />
        </intent>
    </queries>

    <application ...>
        ...
    </application>
</manifest>
```

**Change 2:** Inside the `<activity>` tag, add the `flutter_deeplinking_enabled` metadata and the intent filter. Your activity block will look like:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">

    <!-- Tells Flutter to hand incoming deep link URIs to the router -->
    <meta-data
        android:name="flutter_deeplinking_enabled"
        android:value="true" />

    <!-- Keep the existing launcher intent filter unchanged -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>

    <!-- Custom scheme deep links: mobileflutterdemo:///article/12345 -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="mobileflutterdemo" />
    </intent-filter>

</activity>
```

**Why `flutter_deeplinking_enabled`?** This metadata flag tells the Flutter engine to forward the incoming Android Intent URI to the platform's `RouteInformationProvider`. go_router picks it up and tries to match it against your routes.

**URL format — triple slash matters:** The deep link URL is `mobileflutterdemo:///article/12345` (three slashes, not two). In URI syntax, `scheme://authority/path`. Double slash (`mobileflutterdemo://article/12345`) treats `article` as the *authority* (host), so the path is only `/12345` — go_router would never match `/article/:id`. Triple slash (`mobileflutterdemo:///article/12345`) has an empty authority and `/article/12345` as the path, which matches your route perfectly.

**Test the deep link with adb** (with the app already running in the background on the emulator):

```
adb shell am start -W -a android.intent.action.VIEW -d "mobileflutterdemo:///article/12345"
```

Replace `12345` with any real article ID from your feed. The app should immediately navigate to that article's detail page.

---

## Step 7: Tests

### 7a. Repository unit test

`test/features/article/data/article_detail_repository_impl_test.dart`

This mirrors the Phase 2 repository tests. Use `http_mock_adapter` to intercept Dio calls.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_api.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_repository_impl.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ArticleDetailRepositoryImpl repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://dev.to/api'));
    adapter = DioAdapter(dio: dio);
    repo = ArticleDetailRepositoryImpl(api: ArticleDetailApi(dio: dio));
  });

  test('returns ArticleDetail on 200', () async {
    adapter.onGet('/articles/1', (server) => server.reply(200, _fakeJson));
    final result = await repo.getArticleDetail(id: 1);
    expect(result, isA<Ok>());
    expect((result as Ok).value.id, 1);
    expect((result).value.bodyMarkdown, contains('Hello'));
  });

  test('returns Err on 404', () async {
    adapter.onGet('/articles/999', (server) => server.reply(404, null));
    final result = await repo.getArticleDetail(id: 999);
    expect(result, isA<Err>());
  });
}

const _fakeJson = {
  'id': 1,
  'title': 'Test Article',
  'description': 'A test',
  'body_markdown': '# Hello\n\nWorld.',
  'url': 'https://dev.to/test',
  'published_at': '2024-01-01T00:00:00Z',
  'tag_list': ['flutter'],
  'positive_reactions_count': 10,
  'comments_count': 2,
  'reading_time_minutes': 1,
  'cover_image': null,
  'user': {
    'username': 'testuser',
    'profile_image': 'https://example.com/img.jpg',
  },
};
```

### 7b. Controller unit test

`test/features/article/presentation/article_detail_controller_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_flutter_demo/core/failure.dart';
import 'package:mobile_flutter_demo/core/result.dart';
import 'package:mobile_flutter_demo/features/article/data/article_detail_repository_impl.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail.dart';
import 'package:mobile_flutter_demo/features/article/domain/article_detail_repository.dart';
import 'package:mobile_flutter_demo/features/article/presentation/article_detail_controller.dart';

class MockArticleDetailRepository extends Mock
    implements ArticleDetailRepository {}

void main() {
  test('state is AsyncData on success', () async {
    final mock = MockArticleDetailRepository();
    when(() => mock.getArticleDetail(id: 1))
        .thenAnswer((_) async => Ok(_fakeDetail));

    final container = ProviderContainer(
      overrides: [
        articleDetailRepositoryProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      articleDetailControllerProvider(1).future,
    );
    expect(result.id, 1);
    expect(result.title, 'Test');
  });

  test('state is AsyncError on failure', () async {
    final mock = MockArticleDetailRepository();
    when(() => mock.getArticleDetail(id: 1))
        .thenAnswer((_) async => const Err(NotFoundFailure()));

    final container = ProviderContainer(
      overrides: [
        articleDetailRepositoryProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(articleDetailControllerProvider(1).future),
      throwsA(isA<NotFoundFailure>()),
    );
  });
}

final _fakeDetail = ArticleDetail(
  id: 1,
  title: 'Test',
  description: 'A description',
  bodyMarkdown: '# Hello',
  url: 'https://dev.to/test',
  username: 'user',
  userProfileImage: 'https://example.com/img.jpg',
  positiveReactionsCount: 5,
  commentsCount: 1,
  readingTimeMinutes: 1,
  publishedAt: DateTime(2024),
  tags: const ['flutter'],
);
```

**New pattern here — `ProviderContainer`:** In widget tests you use `ProviderScope`. In pure unit tests (no widgets) you use `ProviderContainer` directly. It's the lower-level primitive that `ProviderScope` wraps. Always call `addTearDown(container.dispose)` to prevent provider leaks between tests.

**`overrideWithValue`:** For a non-generated repository provider, pass the mock directly. This is simpler than `overrideWith` when the override is just a constant value.

### 7c. Golden test for ArticleHeader

`test/features/article/presentation/article_header_golden_test.dart`

Golden tests capture the rendered output of a widget as a PNG. On first run they generate the "golden" image. On subsequent runs they compare against it — great for catching accidental visual regressions.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/article_header.dart';

void main() {
  testWidgets('ArticleHeader matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 240,
            child: ArticleHeader(
              coverImageUrl: 'https://picsum.photos/800/240',
              articleId: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump(); // Let CachedNetworkImage begin loading

    await expectLater(
      find.byType(ArticleHeader),
      matchesGoldenFile('goldens/article_header.png'),
    );
  });
}
```

**Generate the golden file on first run:**

```
flutter test test/features/article/presentation/article_header_golden_test.dart --update-goldens
```

Subsequent runs (e.g., in CI) omit `--update-goldens` and will fail if the widget renders differently.

**Note on network images in tests:** `CachedNetworkImage` won't download the image in tests — it will show the placeholder. That's fine; the placeholder colour is deterministic and the test still verifies layout and widget structure.

Run all tests:

```
flutter test
```

---

## Verification Checklist

Work through these checks on an Android emulator after running `flutter run`:

### Navigation & animation
- [ ] Tap any article card with a cover image → Hero animation: the image smoothly flies from the card to fill the detail page header
- [ ] Tap an article card *without* a cover image → navigation still works, compact app bar shows title only
- [ ] Press the device back button from the detail page → Hero animates in reverse; feed scroll position is exactly where you left it

### Content rendering
- [ ] Scroll the detail page → article title stays pinned in the app bar as the cover image collapses
- [ ] Code blocks in the article render with a distinct background colour
- [ ] Tap a hyperlink in the article body → the link opens in the system browser (not inside the app)
- [ ] Long-press text in the article body → OS text selection handles appear (`selectable: true` working)

### Share
- [ ] Tap the share icon in the top-right → OS share sheet appears with the article URL
- [ ] Dismiss the share sheet → returns to article (no crash)

### Error & retry
- [ ] Enable airplane mode, then tap a card → loading spinner → error message + "Retry" button
- [ ] Re-enable WiFi, tap "Retry" → article loads successfully

### Deep link
- [ ] With the app in the background, run `adb shell am start -W -a android.intent.action.VIEW -d "mobileflutterdemo:///article/12345"` (replace 12345 with a real ID) → app opens directly to that article
- [ ] Deep link to a non-existent article ID → error state shows correctly

### Accessibility
- [ ] Enable TalkBack → tap the share button → TalkBack announces "Share article, button"
- [ ] In Accessibility settings, set font scale to 200% → article text reflows without overflow errors

### Tests
- [ ] `flutter test` passes with no failures
- [ ] `flutter analyze` passes with no warnings

---

## What's Next (Phase 4 Preview)

Phase 3 completes the read path of the app. Phase 4 (Search & Tags) wires up the Search tab with a debounced text field, tag chips, and recent search history. You'll meet two new Riverpod patterns: provider composition (one provider watching another) and async cancellation via Dio's `CancelToken` — cleaning up in-flight requests when a new query arrives.
