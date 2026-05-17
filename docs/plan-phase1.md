# Phase 1 — Foundations: Detailed Implementation Plan

## Context

[plan-overview.md](plan-overview.md) defines a six-phase roadmap evolving MobileFlutterDemo into a Medium-like dev.to reader. Phase 1's job is to **swap out the scaffold without changing what the user sees**: replace the single-file `HomeShell` (`setState` + `IndexedStack` + `NavigationBar`) with a production-grade structure — Riverpod codegen, `go_router` `StatefulShellRoute.indexedStack`, Material 3 with dynamic color, feature-first folders, strict lints — while the four-tab UI continues to look and behave identically. This is the only phase whose end-state UI is unchanged; everything afterwards builds on these primitives, so getting the bones right matters more than shipping features.

Current state (verified):
- [lib/main.dart](../lib/main.dart) — 127 lines, single file, `_TabSpec` list, stateful `_HomeShellState` with `IndexedStack` + `NavigationBar` + per-tab `AppBar.title`.
- [pubspec.yaml](../pubspec.yaml) — only `cupertino_icons` and `flutter_lints`. No state mgmt, no router, no codegen.
- [analysis_options.yaml](../analysis_options.yaml) — bare `flutter_lints`.
- [test/widget_test.dart](../test/widget_test.dart) — one test asserting AppBar title changes when "Search" destination is tapped.

## Decisions locked for this phase

| Decision | Choice |
|---|---|
| Per-tab AppBar | Keep shell-level AppBar that shows the active tab's label (visual parity with current app). |
| Native URL scheme / deep linking | Defer to Phase 3. Phase 1 is pure Dart/Flutter. |
| Dart/Flutter SDK floor | Bump `environment.sdk` to `^3.5.0`; Flutter ≥ 3.41 documented in README. |
| ProviderObserver / logging | Skip; add in Phase 2 when there's real state to log. |
| Generated files (`.g.dart`) | Committed to git (per overview). |
| Riverpod codegen output | Default `.g.dart` next to source — no `build.yaml` overrides. |
| Initial route | `/feed` (Home tab is the future feed). |
| Package name | Keep `mobile_flutter_demo` — renaming cascades through test imports for no Phase 1 benefit. |

## Implementation sequence

Order matters: tooling first so `flutter analyze` is green at every step.

### Step 1 — Tooling baseline

Edit [pubspec.yaml](../pubspec.yaml):
- `environment.sdk: ^3.5.0`
- Add to `dependencies`: `flutter_riverpod: ^2.6.0`, `riverpod_annotation: ^2.6.0`, `go_router: ^14.0.0`, `dynamic_color: ^1.7.0`.
- Add to `dev_dependencies`: `very_good_analysis: ^7.0.0`, `build_runner: ^2.4.0`, `riverpod_generator: ^2.6.0`, `custom_lint: ^0.7.0`, `riverpod_lint: ^2.6.0`.
- Remove `flutter_lints` from `dev_dependencies`.

Replace [analysis_options.yaml](../analysis_options.yaml):
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

Run: `flutter pub get`.

### Step 2 — Folder skeleton

Create empty dirs / placeholder files (each created in later steps; listed here so the layout is one glance):

```
lib/
  main.dart                                  # rewritten in Step 8
  app/
    app.dart
    router.dart                              # has @riverpod codegen
    theme.dart
  core/
    env/app_env.dart
    widgets/app_scaffold.dart
  features/
    feed/presentation/feed_page.dart
    search/presentation/search_page.dart
    activity/presentation/activity_page.dart
    profile/presentation/profile_page.dart
test/
  app/router_test.dart                       # replaces test/widget_test.dart
```

Delete [test/widget_test.dart](../test/widget_test.dart) once `router_test.dart` is green (Step 10).

### Step 3 — `AppEnv` (env config)

`lib/core/env/app_env.dart` — typed wrapper over `--dart-define`. Phase 1 only needs the dev.to base URL so Phase 2 can read it.

```dart
class AppEnv {
  const AppEnv({required this.devtoBaseUrl});

  factory AppEnv.fromEnvironment() => const AppEnv(
        devtoBaseUrl: String.fromEnvironment(
          'DEVTO_BASE_URL',
          defaultValue: 'https://dev.to/api',
        ),
      );

  final String devtoBaseUrl;
}
```

Expose via a simple Riverpod provider (codegen) in the same file:
```dart
@riverpod
AppEnv appEnv(AppEnvRef ref) => AppEnv.fromEnvironment();
```

### Step 4 — Theme

`lib/app/theme.dart` — `buildLightTheme(ColorScheme?)` and `buildDarkTheme(ColorScheme?)` that take optional dynamic-color schemes and fall back to `ColorScheme.fromSeed(seedColor: Colors.indigo)`. Both return `ThemeData(useMaterial3: true, colorScheme: scheme)`.

No Riverpod here; `app.dart` wraps `MaterialApp.router` in a `DynamicColorBuilder` and passes the resolved schemes to these helpers.

### Step 5 — Tab specs + AppScaffold

`lib/core/widgets/app_scaffold.dart`:
- Top-level `const List<AppTabSpec> appTabs` with the four tabs (label, outlined icon, filled icon). Move the existing `_TabSpec` list out of `main.dart` verbatim, minus the `body` field (routes own the body now).
- `class AppScaffold extends StatelessWidget` taking `StatefulNavigationShell navigationShell`.
- Builds `Scaffold` with:
  - `AppBar(title: Text(appTabs[navigationShell.currentIndex].label), centerTitle: true)`
  - `body: navigationShell`
  - `bottomNavigationBar: NavigationBar(selectedIndex: navigationShell.currentIndex, onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex))`
  - destinations mapped from `appTabs`.

`initialLocation: i == currentIndex` makes re-tapping the active tab pop to that branch's root (idiomatic go_router pattern).

### Step 6 — Feature pages

Four files, each a `StatelessWidget` reusing the same placeholder pattern from current `main.dart`:

```dart
// lib/features/feed/presentation/feed_page.dart
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const _PlaceholderBody(title: 'Home', icon: Icons.home);
}
```

Lift `_PlaceholderBody` into `lib/core/widgets/app_scaffold.dart` (or a sibling `placeholder_body.dart`) so all four pages share it. Phase 2 deletes `FeedPage`'s placeholder body; the other three keep it until their phases.

### Step 7 — Router

`lib/app/router.dart` — Riverpod-codegen provider building a `GoRouter`:

```dart
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/feed',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/feed', builder: (_, __) => const FeedPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/activity', builder: (_, __) => const ActivityPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
}
```

No `parentNavigatorKey` yet — Phase 3 introduces it when the article detail route lands outside the shell.

### Step 8 — App entrypoint

`lib/app/app.dart`:

```dart
class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'MobileFlutterDemo',
        theme: buildLightTheme(lightDynamic),
        darkTheme: buildDarkTheme(darkDynamic),
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
```

Collapse [lib/main.dart](../lib/main.dart) to ~5 lines:

```dart
void main() {
  runApp(const ProviderScope(child: App()));
}
```

The overview is explicit: `main.dart` only bootstraps `ProviderScope + runApp` and never grows. This is the line we're drawing now.

### Step 9 — Codegen

Run once: `dart run build_runner build --delete-conflicting-outputs`.

Expected generated files (committed):
- `lib/app/router.g.dart`
- `lib/core/env/app_env.g.dart`

Document the watch workflow in README appendix:
- During dev: `dart run build_runner watch --delete-conflicting-outputs`
- Cold rebuild: `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs`

### Step 10 — Tests

Replace [test/widget_test.dart](../test/widget_test.dart) with `test/app/router_test.dart`. One test:

1. `pumpWidget(ProviderScope(child: App()))`
2. `pumpAndSettle`
3. Assert AppBar title is `Home`, current location is `/feed` via `find` on a `Builder` context that calls `GoRouterState.of(context).matchedLocation`. (Pragmatic alternative: assert the active tab page widget type is found.)
4. For each of `Search`, `Activity`, `Profile`:
   - `tester.tap(find.widgetWithText(NavigationDestination, label))`
   - `pumpAndSettle`
   - Assert AppBar title and matched location.

Run: `flutter analyze && flutter test`.

## Critical files

| File | Action |
|---|---|
| [pubspec.yaml](../pubspec.yaml) | Add 4 deps + 5 dev_deps; remove flutter_lints; bump SDK to `^3.5.0`. |
| [analysis_options.yaml](../analysis_options.yaml) | Switch to `very_good_analysis` + custom_lint plugin, exclude generated files. |
| [lib/main.dart](../lib/main.dart) | Collapse to ~5 lines; `runApp(ProviderScope(child: App()))`. |
| `lib/app/app.dart` | New — `MaterialApp.router` + `DynamicColorBuilder`. |
| `lib/app/router.dart` | New — `@riverpod GoRouter` with `StatefulShellRoute.indexedStack`. |
| `lib/app/theme.dart` | New — light/dark theme builders with dynamic-color fallbacks. |
| `lib/core/env/app_env.dart` | New — `AppEnv` + `@riverpod` provider. |
| `lib/core/widgets/app_scaffold.dart` | New — `AppScaffold` + `appTabs` + `_PlaceholderBody`. |
| `lib/features/{feed,search,activity,profile}/presentation/<name>_page.dart` | New — four placeholder `StatelessWidget`s. |
| [test/widget_test.dart](../test/widget_test.dart) | Delete after Step 10. |
| `test/app/router_test.dart` | New — replacement test using `ProviderScope(child: App())`. |

## Verification

After Step 10, all of these must pass:

1. `flutter pub get` — clean exit.
2. `dart run build_runner build --delete-conflicting-outputs` — clean exit; `router.g.dart` and `app_env.g.dart` present.
3. `flutter analyze` — zero issues under `very_good_analysis`.
4. `flutter test` — `router_test.dart` passes.
5. `flutter run` on Android emulator:
   - App opens to **Home** tab; AppBar reads "Home"; placeholder icon centered.
   - Tap each tab in turn → AppBar title updates; URL behind the scenes updates (debug log via go_router's `debugLogDiagnostics: true` if enabled).
   - Scroll behavior in a placeholder is N/A this phase; the persistence test comes Phase 2 once `ListView` content exists. **In Phase 1, validate IndexedStack semantics by tapping Home → Search → Home and confirming no jump/rebuild flash** (indexedStack keeps each branch mounted).
6. Toggle device dark mode in Settings → theme flips immediately (no app restart).
7. On a Pixel 6+ emulator running Android 12+: launcher accent reflected in app's primary color (dynamic color path). On older emulators or iOS: indigo fallback used.
8. Manual deep-link check **deferred to Phase 3** — no native manifest changes this phase.

## Out of scope (explicit — do not pull in)

- Article models, dev.to HTTP client, dio, freezed, json_serializable → Phase 2.
- `parentNavigatorKey`, deep linking, `/article/:id` route → Phase 3.
- Any `Drift`, `shared_preferences`, persistence → Phase 5.
- `ProviderObserver`, logging interceptor, error UI components → later phases.
- App icon / launcher resources / bundle ID rename — not required for the teaching goal.
