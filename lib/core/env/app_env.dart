import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_env.g.dart';

class AppEnv {
  const AppEnv({required this.devtoBaseUrl});

  factory AppEnv.fromEnvironment() => const AppEnv(
        devtoBaseUrl: String.fromEnvironment(
          'DEVTO_BASE_URL',
          defaultValue: 'https://dev.to/api',
        ),
      );

  final String devtoBaseUrl;
}

@riverpod
AppEnv appEnv(AppEnvRef ref) => AppEnv.fromEnvironment();
