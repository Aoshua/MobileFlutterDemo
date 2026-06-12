import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({required this.url, super.key});
  final String url;

  @override
  Widget build(BuildContext context) {
    // Semantics: TalkBack (Android) & VoiceOver (iOS) use the
    // semantic tree to describe UI to users who can't see the screen.
    return Semantics(
      label: 'Share article',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.share_outlined),
        tooltip: 'Share',
        // OS handles the sheet, apps, & animation
        onPressed: () => Share.share(url),
      ),
    );
  }
}
