import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/feed_controller.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/widgets/article_card.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/widgets/article_card_skeleton.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/widgets/feed_empty_view.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/widgets/feed_error_view.dart';

// ConsumerWidget is the Riverpod equivalent of StatelessWidget.
// It adds WidgetRef ref parameter to build.
class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);

    return RefreshIndicator(
      // ref.read() subscribes this widget to the controller's
      // AsyncValue<List<Article>> state and rebuilds on every change.
      onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
      child: state.when(
        loading: () => const _SkeletonList(),
        error: (_, __) => FeedErrorView(
          // ref.invalidate() disposes of the provider and re-runs build from
          // scratch, which is the cleanest "retry" mechanism.
          onRetry: () => ref.invalidate(feedControllerProvider),
        ),
        data: (articles) {
          if (articles.isEmpty) return const FeedEmptyView();
          // ListView.builder() builds items lazily (only when on-screen)
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
