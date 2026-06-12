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
    final pixelWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .toInt();

    // Hero is Flutter's built-in shared-element transition. After
    // wrapping local widgets in their own Hero(tag: ...) in each
    // screen, during navigation transition Flutter finds the
    // matching tags and smoothly morphs one into the other.
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
