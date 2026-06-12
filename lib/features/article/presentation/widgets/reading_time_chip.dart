import 'package:flutter/material.dart';

class ReadingTimeChip extends StatelessWidget {
  const ReadingTimeChip({required this.minutes, super.key});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.timer_outlined, size: 16),
      label: Text('$minutes min read'),
      visualDensity: VisualDensity.compact,
    );
  }
}
