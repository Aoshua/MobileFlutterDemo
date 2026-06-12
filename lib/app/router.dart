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
