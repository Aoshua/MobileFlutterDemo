import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter_demo/app/router.dart';
import 'package:mobile_flutter_demo/app/theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'MobileFlutterDemo',
        theme: buildLightTheme(lightDynamic),
        darkTheme: buildDarkTheme(darkDynamic),
        routerConfig: router,
      ),
    );
  }
}
