import 'package:flutter/material.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, super.key});
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
            // Inserts a widget only when condition is true
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
            // Conditionally insert many widgets
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
