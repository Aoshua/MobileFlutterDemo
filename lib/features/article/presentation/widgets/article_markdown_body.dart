import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class ArticleMarkdownBody extends StatelessWidget {
  const ArticleMarkdownBody({required this.markdown, super.key});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return md.MarkdownBody(
      data: markdown,
      selectable: true, // Long press to copy text
      // fromTheme will apply our Material 3 theming to the markdown content
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
