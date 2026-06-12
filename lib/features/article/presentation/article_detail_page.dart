import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter_demo/features/article/presentation/article_detail_controller.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/article_header.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/article_markdown_body.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/reading_time_chip.dart';
import 'package:mobile_flutter_demo/features/article/presentation/widgets/share_button.dart';

class ArticleDetailPage extends ConsumerWidget {
  const ArticleDetailPage({required this.articleId, super.key});
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
              const Text('Failed to load artile'),
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
          // Slivers solve mixing a collapsing app bar with a scrollable body.
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
                      child: ArticleMarkdownBody(
                        markdown: article.bodyHtml,
                      ),
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
