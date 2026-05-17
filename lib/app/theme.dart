import 'package:flutter/material.dart';

const _fallbackSeed = Colors.indigo;

ThemeData buildLightTheme(ColorScheme? dynamicScheme) {
  final scheme = dynamicScheme ??
      ColorScheme.fromSeed(seedColor: _fallbackSeed);
  return ThemeData(useMaterial3: true, colorScheme: scheme);
}

ThemeData buildDarkTheme(ColorScheme? dynamicScheme) {
  final scheme = dynamicScheme ??
      ColorScheme.fromSeed(
        seedColor: _fallbackSeed,
        brightness: Brightness.dark,
      );
  return ThemeData(useMaterial3: true, colorScheme: scheme);
}
