import 'package:flutter/material.dart';
import 'package:mobile_flutter_demo/features/feed/domain/article.dart';
import 'package:mobile_flutter_demo/features/feed/presentation/widgets/article_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  Widget build(BuildContext context) =>
      Skeletonizer(child: ArticleCard(article: _fake));

  // skeletonizer wraps any widget and replaces its painted content with shimmer
  // rectangles of the exact same shape. You pass a real widget with fake data
  // then the library handles the animation.
}
