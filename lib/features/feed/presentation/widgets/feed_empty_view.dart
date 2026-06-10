import 'package:flutter/material.dart';

class FeedEmptyView extends StatelessWidget {
  const FeedEmptyView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No articles found.'));
}
