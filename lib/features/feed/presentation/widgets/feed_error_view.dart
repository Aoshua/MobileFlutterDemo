import 'package:flutter/material.dart';

class FeedErrorView extends StatelessWidget {
  const FeedErrorView({required this.onRetry, super.key});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Icon(Icons.cloud_off, size: 64),
        const SizedBox(height: 16),
        const Text('Failed to load articles'),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
