# Plan: Migrate Android App to Flutter Built-in Kotlin

## Context

Flutter is deprecating direct application of the Kotlin Gradle Plugin (KGP) by app projects and plugins in favor of "Built-in Kotlin" — the Flutter Gradle Plugin now manages Kotlin compilation itself. The project currently applies KGP explicitly in `android/app/build.gradle.kts`, which triggers the warning. A second warning comes from the `dynamic_color` plugin (v1.7.0) applying KGP internally; that requires a plugin upgrade.

## Changes

### 1. `android/app/build.gradle.kts`

Remove the explicit KGP plugin application and the `kotlinOptions` block (Flutter's built-in Kotlin handles JVM target automatically):

**Remove** `id("kotlin-android")` from the `plugins {}` block.

**Remove** the entire `kotlinOptions` block:
```kotlin
kotlinOptions {
    jvmTarget = JavaVersion.VERSION_17.toString()
}
```

After the change the `plugins {}` block becomes:
```kotlin
plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
```

### 2. `android/settings.gradle.kts`

Remove the KGP definition since nothing in the app project applies it anymore:

**Remove** this line:
```kotlin
id("org.jetbrains.kotlin.android") version "2.2.20" apply false
```

### 3. `dynamic_color` plugin warning

The `dynamic_color` plugin (v1.7.0) applies KGP internally — this cannot be fixed by app-level changes. The fix is to upgrade the plugin in `pubspec.yaml`:

- Run `flutter pub upgrade dynamic_color` to pull the latest compatible version.
- If no migration-compatible version exists yet, the warning is benign (build still succeeds) and should be monitored.

## Verification

1. Run `flutter build apk --debug` (or launch on emulator) — should build without the KGP warnings.
2. Confirm the app launches and renders correctly on the emulator.
