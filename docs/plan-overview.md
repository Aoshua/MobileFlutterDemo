# Flutter Best-Practices Roadmap — Evolving MobileFlutterDemo into a Medium-like Blog Reader

## Context

[lib/main.dart](../lib/main.dart) is today a clean greenfield Flutter 3.41+ scaffold: a single file with a stateful `HomeShell` driving an `IndexedStack` over four placeholder tabs (Home, Search, Activity, Profile), plus one widget test. No state management, routing, networking, persistence, or codegen — the ideal starting point.

The blog reader is the **vehicle**, not the goal. The real purpose is teaching idiomatic Flutter in 2026: **Riverpod with code generation, `go_router` declarative navigation, `freezed`/`json_serializable` immutable models, repository pattern, layered async state, the testing pyramid, and feature-first architecture**. Each phase ends in a runnable app on Android/iOS emulators so you can pause, internalize, and ship at every checkpoint.

Data source throughout: the **dev.to public REST API** (`https://dev.to/api`) — no auth, real-world JSON, real pagination, real markdown bodies.

---

## Goals & Non-Goals

### Goals
- Modern **Riverpod 2026** patterns (codegen providers, `AsyncNotifier`, `family`, autoDispose, `ref.listen`).
- **Feature-first architecture** with clean `data` / `domain` / `presentation` split.
- The **testing pyramid**: unit (repositories w/ `mocktail`), widget (`ProviderScope` overrides), golden, integration.
- **Declarative navigation** with `go_router`, including `StatefulShellRoute` + deep linking.
- **Immutable models + JSON** with `freezed` + `json_serializable` + `build_runner`.
- **Performance hygiene**: `const`, `ListView.builder`, `RepaintBoundary`, DevTools profiling.
- **Accessibility** (semantics, dynamic text scaling) and **theming** (Material 3, light/dark, dynamic color).
- **Offline-first** persistence with a reactive local DB.

### Non-Goals
- No web/desktop targets — Android + iOS only.
- No Firebase, no auth, no analytics SDKs.
- No real publishing to dev.to (write endpoints need an API key).
- No state-management bake-off — Riverpod only, learned deeply.
- No backend code — dev.to is the backend.

---

## Locked-in Architectural Decisions (Phase 1, justified throughout)

| Decision | Choice | Why this for teaching |
|---|---|---|
| State management | **Riverpod 2.x + `riverpod_generator`** | Codegen forces declarative thinking, removes boilerplate, teaches modern Dart 3 patterns. |
| Routing | **`go_router`** (over `auto_route`) | Official team support; URL-based routing maps cleanly to deep linking; less codegen surface. |
| Models | **`freezed` + `json_serializable`** | Industry standard; teaches sealed unions, `copyWith`, value equality. |
| HTTP | **`dio`** (over `http`) | Interceptors, cancellation tokens, typed errors — what production apps look like. |
| Folder layout | **`lib/{core,features}` with `features/<name>/{data,domain,presentation}`** | Scales; mirrors Clean Architecture; each feature deletable as a unit. |
| Error handling | **`Result<T, AppFailure>` sealed type** | Forces exhaustive `switch`; leverages Dart 3 patterns; explicit async UX states. |
| Local DB (Phase 5) | **Drift** (over Isar/Hive) | Stable in 2026, reactive streams, type-safe SQL, teaches transferable SQL. |
| Markdown | **`flutter_markdown_plus`** | Maintained fork; supports custom builders / syntax extensions. |
| Lints | **`very_good_analysis`** | Stricter than `flutter_lints`; production-app baseline. |
| Codegen runner | **`build_runner watch --delete-conflicting-outputs`** | Standard 2026 workflow; generated files committed (simpler CI, faster cold clones). |

---

# Phase 1 — Foundations

**Outcome:** Same 4 tabs render, but on a production-grade scaffold: Riverpod, `go_router` ShellRoute driving bottom nav, strict lints, Material 3 dynamic color + dark mode, env config, feature-first folder layout.

**Size:** Medium.

### Best-practice concepts taught
- Feature-first folder layout (`lib/core` + `lib/features/<feature>/{data,domain,presentation}`).
- Riverpod with code generation (`@riverpod` annotation, autoDispose by default).
- Declarative routing with `go_router` `StatefulShellRoute.indexedStack` for persistent bottom nav.
- Material 3 theming: `ColorScheme.fromSeed`, `ThemeMode`, `DynamicColorBuilder`.
- Strict static analysis (`very_good_analysis`) + `riverpod_lint` via `custom_lint`.
- Env config via `--dart-define` and a typed `AppEnv` class.
- `build_runner` workflow and what to (not) gitignore.

### Concrete deliverables

**Packages (dependencies):** `flutter_riverpod ^2.6`, `riverpod_annotation ^2.6`, `go_router ^14`, `dynamic_color ^1.7`
**Packages (dev_dependencies):** `very_good_analysis ^7`, `build_runner ^2.4`, `riverpod_generator ^2.6`, `custom_lint ^0.7`, `riverpod_lint ^2.6`

**Folder structure created:**
```
lib/
  main.dart                          # only bootstraps ProviderScope + runApp
  app/
    app.dart                         # MaterialApp.router
    router.dart                      # GoRouter + StatefulShellRoute
    theme.dart                       # light/dark + dynamic color
  core/
    env/app_env.dart
    widgets/app_scaffold.dart
  features/
    feed/presentation/feed_page.dart        # placeholder
    search/presentation/search_page.dart    # placeholder
    activity/presentation/activity_page.dart
    profile/presentation/profile_page.dart
test/app/router_test.dart            # replaces test/widget_test.dart
```

### Key decisions
| Decision | Choice | Reasoning |
|---|---|---|
| Riverpod flavor | `flutter_riverpod` + `riverpod_generator` | Codegen for type safety; legacy `StateNotifierProvider` is out. |
| Router | `go_router` with `StatefulShellRoute.indexedStack` | Built-in persistent state per tab, mirrors current `IndexedStack` semantics. |
| Folder layout | `core` + `features/<f>/{data,domain,presentation}` | Three-layer split per feature; `core` for cross-cutting infra. |
| Dynamic color | `dynamic_color` package, fallback to indigo seed | Android 12+ users get system color. |
| Generated files in git | **Commit `.g.dart` / `.freezed.dart`** | Simpler CI, faster cold clones, clearer review. |

### Verification
- `flutter pub get && dart run build_runner build --delete-conflicting-outputs` succeeds.
- `flutter analyze` clean under `very_good_analysis`.
- `flutter run` on Android emulator: identical 4-tab UI; tab scroll position persists.
- Toggle device dark mode: theme switches.
- `flutter test` runs `router_test.dart` (tap each destination, assert route updates via `GoRouterState`).

---

# Phase 2 — Feed (Read-Only)

**Outcome:** Home tab loads the dev.to feed with pagination, pull-to-refresh, skeleton loading, typed error state. Tapping does nothing yet.

**Size:** Large — the dense one. Most data-layer concepts land here.

### Best-practice concepts taught
- Immutable models with `freezed` + `json_serializable` (`@JsonKey`, `DateTime` parsing).
- Repository pattern: abstract repo in `domain/`, impl in `data/`, provider in `presentation/`.
- `dio` with interceptors (logging in debug, retry on 5xx); typed `AppFailure` mapping.
- `Result<T, AppFailure>` sealed type; UI `switch`-es on it.
- Riverpod `AsyncNotifier` (`@riverpod class FeedController extends _$FeedController`) for paginated state.
- `AsyncValue` patterns: `.when` vs `valueOrNull` + skeleton overlay.
- `ListView.builder` + sentinel tile triggers page N+1.
- Skeleton loading (`skeletonizer`).
- Pull-to-refresh by invalidating the notifier.
- Repository unit tests with `mocktail` + `http_mock_adapter`.

### Concrete deliverables

**Packages:** `dio ^5.7`, `freezed_annotation ^2.4`, `json_annotation ^4.9`, `skeletonizer ^1.4` (+ dev: `freezed ^2.5`, `json_serializable ^6.8`, `mocktail ^1`, `http_mock_adapter ^0.6`).

**Folder additions:**
```
lib/core/network/        # dio_client.dart, logging_interceptor.dart, retry_interceptor.dart, api_exception.dart
lib/core/result.dart     # sealed Result<T, AppFailure>
lib/core/failure.dart    # sealed AppFailure
lib/features/feed/
  data/      dto/article_dto.dart, dto/user_dto.dart, article_api.dart, article_repository_impl.dart
  domain/    article.dart (no JSON), article_repository.dart (abstract)
  presentation/  feed_page.dart, feed_controller.dart, widgets/{article_card,article_card_skeleton,feed_error_view,feed_empty_view}.dart
test/features/feed/{data,presentation}/...
```

### Key decisions
| Decision | Choice | Reasoning |
|---|---|---|
| HTTP client | `dio` | Interceptors + typed exception mapping are core teaching moments. |
| DTO vs domain model | **Separate** | Anti-corruption layer — domain model never knows about JSON. |
| Pagination | `?page=N&per_page=20`, cursor in notifier state | Real-world; state-driven. |
| Skeleton library | `skeletonizer` (over hand-rolled `shimmer`) | Same shape as loaded UI — teaches a UX principle. |
| Mocking | `mocktail` (no codegen) | Lighter; no `build_runner` rebuilds on signature changes. |

### Verification
- Cold start: ~6 skeleton cards, then real articles.
- Scroll to bottom: page 2 loads with end-of-list loader.
- Pull down: refresh, list resets to page 1.
- Airplane mode mid-load: error view + retry button.
- Tests: repository handles 200/404/500/malformed/timeout → correct `AppFailure`; controller transitions `AsyncLoading → AsyncData`; widget pump asserts skeleton then cards.

---

# Phase 3 — Article Detail

**Outcome:** Tap a card → detail screen with Hero-animated cover, markdown body, reading time, share button, deep-linkable URL (`/article/:id`).

**Size:** Medium.

### Best-practice concepts taught
- Deep linking with `go_router` path params + Android intent filter testing via `adb`.
- Hero animations across navigation boundaries.
- Markdown with custom builders (code blocks, headings, links).
- `cached_network_image` — disk + memory caching, placeholders.
- Riverpod `family` providers (`articleDetailProvider(int id)`).
- `RepaintBoundary` around markdown body for scroll perf.
- Platform share sheet via `share_plus`.
- Accessibility: `Semantics`, `Image.semanticLabel`, dynamic text scaling.

### Concrete deliverables

**Packages:** `flutter_markdown_plus ^1`, `cached_network_image ^3.4`, `share_plus ^10`, `url_launcher ^6.3`.

**Folder additions:**
```
lib/features/article/
  data/article_detail_api.dart, article_detail_repository_impl.dart
  domain/article_detail.dart (with body_markdown), article_detail_repository.dart
  presentation/article_detail_page.dart, article_detail_controller.dart
             widgets/markdown_body.dart, article_header.dart, reading_time_chip.dart, share_button.dart
```

**Router updates ([lib/app/router.dart](../lib/app/router.dart)):** new top-level `/article/:id` *outside* the ShellRoute (full-screen, hides bottom nav). `parentNavigatorKey: _rootNavigatorKey`.

### Key decisions
| Decision | Choice | Reasoning |
|---|---|---|
| Detail outside ShellRoute | Yes | Teaches root vs branch navigators. |
| Markdown package | `flutter_markdown_plus` | Maintained fork of the archived original. |
| Hero tag | `'article-cover-${article.id}'` | Stable across feed/detail; teaches Hero pitfalls (dup tags → crash). |
| Image cache | `cached_network_image` with `memCacheWidth` | GPU texture is the memory hog, not bytes. |
| Reading time | Computed in controller (~200 wpm) | "Compute presentation values in the controller, not the widget." |

### Verification
- Smooth Hero into detail page; reverse on back, feed scroll preserved.
- Code blocks render syntax; links open system browser.
- `adb shell am start -W -a android.intent.action.VIEW -d "mobileflutterdemo://article/12345"` opens the article.
- Share sheet appears on tap.
- System font scale 200% → reflows, no overflow.
- TalkBack announces all interactive roles.

---

# Phase 4 — Search & Tags

**Outcome:** Search tab fully wired: debounced text input, tag chips, recent searches, empty/no-results states. Backed by `/articles?tag=` and `/tags`.

**Size:** Medium.

### Best-practice concepts taught
- Debouncing the Riverpod way: `Timer` inside controller + `ref.onDispose`.
- `family` providers parameterized on a freezed `SearchQuery` value class (stable equality for caching).
- Async cancellation via Dio `CancelToken` when a new query arrives.
- Composing providers: `searchResultsProvider` watches `searchQueryProvider` + `selectedTagsProvider`.
- Empty / no-results / error states as UX-first.
- Recent searches via `shared_preferences` (preview of Phase 5).
- `AutomaticKeepAliveClientMixin` for result list state preservation.

### Concrete deliverables

**Packages:** `shared_preferences ^2.3`, `fast_immutable_collections` (for `IList`/`ISet` in query params).

**Folder additions:**
```
lib/features/search/
  data/tag_api.dart, search_api.dart, tag_repository_impl.dart, recent_searches_local.dart
  domain/tag.dart, search_query.dart, tag_repository.dart
  presentation/search_page.dart, search_field.dart, tag_filter_bar.dart, search_results_view.dart
                controllers/{search_query,search_results,tags,recent_searches}_controller.dart
test/features/search/presentation/search_query_controller_test.dart  # uses fake_async for debounce
```

### Key decisions
| Decision | Choice | Reasoning |
|---|---|---|
| Debounce | `Timer` in controller | No rxdart needed for simple cases. |
| Search query model | freezed `SearchQuery` with `IList<String>` tags | Family params need stable equality. |
| Cancellation | `CancelToken` cancelled in `ref.onDispose` | Async hygiene. |
| Immutable collections | `fast_immutable_collections` | Kills a class of mutable-list bugs. |

### Verification
- Rapid typing fires one request per ~400ms.
- Tag chip filter works; deselects on second tap.
- Empty query shows trending tags; no-results state has illustration.
- Recent searches persist across app kill.
- `fake_async` test asserts exactly one request fires per rapid burst.

---

# Phase 5 — Persistence & Bookmarks

**Outcome:** Bookmark toggle on feed cards + detail; bookmarks readable offline; Activity tab shows read history; full app works in airplane mode for viewed content.

**Size:** Large.

### Best-practice concepts taught
- Local-first: read from DB stream, refresh from network in background (**stale-while-revalidate**).
- **Drift** ORM: typed tables, DAOs, reactive `Stream<List<T>>` queries driving Riverpod `StreamProvider`s.
- Database migrations (`schemaVersion`, `MigrationStrategy.onUpgrade`).
- Optimistic UI updates with rollback on failure.
- Heavy initial sync via `compute` isolate.
- Integration tests with `NativeDatabase.memory()`.
- **Evolving an existing repository** (Phase 2's `ArticleRepositoryImpl`) to be cache-aware — a deliberate teaching moment about architecture without rewrites.

### Concrete deliverables

**Packages:** `drift ^2.20`, `drift_flutter ^0.2`, `path_provider ^2.1`, `path ^1.9`, `sqlite3_flutter_libs ^0.5` (+ dev: `drift_dev ^2.20`).

**Folder additions:**
```
lib/core/db/app_database.dart  + tables/{bookmarks,read_history,cached_articles}_table.dart
lib/features/bookmarks/
  data/bookmark_dao.dart, bookmark_repository_impl.dart
  domain/bookmark.dart, bookmark_repository.dart
  presentation/bookmark_button.dart, bookmarks_controller.dart
lib/features/activity/
  data/read_history_dao.dart
  domain/read_event.dart
  presentation/activity_page.dart (no longer placeholder), read_history_controller.dart
test/core/db/app_database_test.dart  # in-memory
test/features/bookmarks/...
```

**Architectural change:** `lib/features/feed/data/article_repository_impl.dart` (created Phase 2) gains cache-aware behavior — write fetched articles to `cached_articles_table`; on offline error fall back to cache.

### Key decisions
| Decision | Choice | Reasoning |
|---|---|---|
| Local DB | **Drift** | Stable 2026, reactive streams, type-safe SQL, transferable skill. Hive lacks query power; Isar 4.x still settling. |
| Codegen mode | Strict + null safety | Teaches `companion` patterns, insert ≠ select types. |
| Sync strategy | Stale-while-revalidate | The 2026 standard; "loading" is rarely binary. |
| Read history insert | `ArticleDetailController.markRead()`, called in `initState` via `ref.read` | The clean way to do side-effects-in-initState. |

### Verification
- Open article → kill app → airplane mode → reopen: article still loads from cache.
- Bookmark from feed: heart fills optimistically; appears in Activity.
- Activity tab sorted by `lastReadAt DESC`.
- In-memory Drift tests verify insert/query/update + stream emissions.
- DevTools Performance: scroll bookmarks list — frames < 16ms.

---

# Phase 6 (Stretch) — Authoring with Local Drafts

**Outcome:** FAB on Home opens compose screen with markdown editor + live preview. Drafts save locally; no remote publish. Profile tab lists "My drafts."

**Size:** Medium.

### Best-practice concepts taught
- Form state with Riverpod (no `Form`/`FormState` boilerplate).
- Field-level validation with sealed `ValidationError` types — pure Dart, easily unit-tested.
- Navigation guards via `go_router`'s `onExit` (replaces `WillPopScope`).
- Split-pane UI: edit/preview toggle (mobile) or side-by-side (tablet).
- Reusing `markdown_body.dart` from Phase 3 — composition.
- Auto-save: `Timer.periodic` in controller, killed in `ref.onDispose`.

### Concrete deliverables

**Packages:** `flutter_keyboard_visibility ^6`.

**Folder additions:**
```
lib/features/authoring/
  data/draft_dao.dart, draft_repository_impl.dart
  domain/draft.dart, draft_repository.dart, draft_validator.dart  # pure Dart
  presentation/compose_page.dart, preview_pane.dart, draft_editor_controller.dart, drafts_list_page.dart
test/features/authoring/domain/draft_validator_test.dart  # pure unit, no Flutter
test/features/authoring/presentation/compose_page_test.dart
```

**Drift schema bump:** new `drafts_table.dart`, `schemaVersion` 1 → 2, migration adds table.

### Verification
- Compose → preview shows identical markdown rendering.
- Background app, return: text preserved (auto-save fired).
- Back with unsaved changes: confirmation dialog.
- Drafts list sorted by `updatedAt`.
- Validator unit tests green.

---

# Cross-Cutting Practices

### Lints (Phase 1, revisited)
- Switch [analysis_options.yaml](../analysis_options.yaml) to `package:very_good_analysis/analysis_options.yaml`.
- Enable `custom_lint` + `riverpod_lint`.
- Phase 2: forbid `print`, require `public_member_api_docs` in `lib/core/`.

### Folder structure rationale
**`lib/{core, features}` with `features/<name>/{data, domain, presentation}`** ("lite Clean Architecture"):
- `core` = cross-cutting infra (DB, network, result types, shared widgets).
- Each feature self-contained — deletable as a unit.
- Three-layer split scales without forcing dependency-inversion theory on week one.

Rejected: top-level `lib/{data,domain,presentation}` — groups by "kind of code," forces every change to touch three dirs.

### Error handling: three-tier discipline
- **Data + domain layers:** return `Result<T, AppFailure>`. Exceptions only inside data layer, caught immediately and mapped.
- **Controller layer:** unwraps `Result` → `AsyncValue`.
- **Widget layer:** consumes `AsyncValue.when` — never sees `Result` directly.

Introduced in Phase 2 and never broken.

### Testing pyramid
| Layer | Tool | Introduced |
|---|---|---|
| Unit (pure Dart) | `flutter_test` + `mocktail` | Phase 2 (repos), Phase 6 (validators) |
| Widget | `flutter_test` + `ProviderScope` overrides | Phase 1 (router), Phase 2 (feed) |
| Golden | `matchesGoldenFile` (or `alchemist`) | Phase 3 (article card, detail header) |
| Integration | `integration_test` | Phase 5 (end-to-end bookmark on emulator) |

### Codegen workflow
- `dart run build_runner watch --delete-conflicting-outputs` open in a terminal during dev.
- Generated files **committed**; documented in Phase 1.
- README: `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs` to rebuild from scratch.

### Performance
- Phase 1: `const` constructors everywhere; lint-enforced.
- Phase 2: `ListView.builder` only.
- Phase 3: `RepaintBoundary` around markdown body.
- Phase 5: DevTools Performance walkthrough — record scroll, find jank, fix with `RepaintBoundary` / `cacheExtent`.

### Accessibility
- Phase 1: respect `MediaQuery.textScalerOf`.
- Phase 3: `Semantics` labels on icon buttons; `Image.semanticLabel` on covers.
- Phase 5: tap targets ≥ 48dp.

### CI (Phase 1 README appendix, refined per phase)
`.github/workflows/flutter.yml`:
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test --coverage`
4. Phase 5+: integration tests on Linux Android emulator (`reactivecircus/android-emulator-runner`).

---

# Verification Summary per Phase

| Phase | Manual emulator check | Automated tests | Perf check |
|---|---|---|---|
| 1 | 4 tabs render, dark mode + dynamic color, route URL updates | `router_test.dart` | n/a |
| 2 | Feed loads/paginates/refreshes/handles offline | Repo unit + controller + widget | `ListView.builder` in DevTools |
| 3 | Tap → Hero + markdown + share; deep link via `adb` | Detail controller + golden | `RepaintBoundary` in timeline |
| 4 | Debounce typing, tag chips, no-results UX | `fake_async` debounce test | n/a |
| 5 | Bookmark survives app kill + airplane mode | In-memory Drift + integration | DevTools scroll recording |
| 6 | Compose, preview, auto-save, nav guard dialog | Validator unit + compose widget | n/a |

---

# Suggested Pacing

- **Phase 1**: a weekend (lots of tooling, no features).
- **Phase 2**: 1–2 weeks (the dense one).
- **Phase 3**: 3–4 days.
- **Phase 4**: 3–4 days.
- **Phase 5**: 1–2 weeks (Drift learning curve + offline-first refactor).
- **Phase 6**: 3–4 days, optional.

**Total**: 5–8 weeks at evening/weekend pace → publishable portfolio-quality Flutter app + deep working knowledge of the 2026 idiomatic stack.

---

# Critical Files

- [pubspec.yaml](../pubspec.yaml) — every phase adds dependencies here.
- [analysis_options.yaml](../analysis_options.yaml) — switched in Phase 1, refined in Phase 2.
- [lib/main.dart](../lib/main.dart) — collapsed in Phase 1; never grows.
- `lib/app/router.dart` *(created Phase 1)* — central router definition, extended in Phase 3.
- `lib/features/feed/data/article_repository_impl.dart` *(created Phase 2)* — the linchpin; Phase 5's offline refactor evolves this in place.
