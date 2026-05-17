# MobileFlutterDemo

A minimal Flutter starter targeting **Android** and **iOS**. Ships a Material 3 app with a top `AppBar` (per-tab title) and a bottom `NavigationBar` containing four tabs — Home, Search, Activity, Profile. Tab state is preserved across switches via `IndexedStack`.

- Flutter SDK: **3.41.x** (stable channel) or newer
- Dart SDK: bundled with Flutter (3.11.x+)
- Package: `mobile_flutter_demo`
- Bundle org: `com.example`

---

## Table of contents

- [Prerequisites](#prerequisites)
- [Project layout](#project-layout)
- [First-time setup](#first-time-setup)
- [Run on Android emulator (Windows / macOS / Linux)](#run-on-android-emulator-windows--macos--linux)
- [Run on a physical Android device (Windows)](#run-on-a-physical-android-device-windows)
- [Run on iOS Simulator (macOS only)](#run-on-ios-simulator-macos-only)
- [Run on a physical iPhone (macOS only)](#run-on-a-physical-iphone-macos-only)
- [Build release artifacts](#build-release-artifacts)
- [Hot reload & hot restart](#hot-reload--hot-restart)
- [Troubleshooting](#troubleshooting)
- [Next steps](#next-steps)

---

## Prerequisites

You need the Flutter SDK plus a platform toolchain for each OS you want to target.

| Platform | What you need | Where to get it |
| --- | --- | --- |
| All | Flutter SDK (stable channel) | https://docs.flutter.dev/get-started/install |
| Android | Android Studio (Ladybug or newer) + Android SDK + cmdline-tools + an AVD **or** a USB device | https://developer.android.com/studio |
| iOS | **macOS**, Xcode 15+, CocoaPods, an iOS Simulator or physical iPhone | App Store (Xcode); `sudo gem install cocoapods` |
| Editor | VS Code **or** Android Studio, with the Flutter + Dart plugins | https://docs.flutter.dev/tools/vs-code |

> **Windows users targeting iOS:** Flutter can *generate* the iOS project from Windows, but **building, signing, and running iOS requires macOS + Xcode**. Use a Mac, a Mac in CI (e.g. Codemagic, GitHub Actions `macos-latest`), or a cloud Mac service.

### Verify the Flutter install

```sh
flutter --version
flutter doctor
```

All categories relevant to your targets should be green. For Android, also run:

```sh
flutter doctor --android-licenses
```

and accept everything.

---~

## Project layout

```
MobileFlutterDemo/
├── android/               # Android host project (Gradle, AndroidManifest, etc.)
├── ios/                   # iOS host project (Xcode workspace, Info.plist, Podfile)
├── lib/
│   └── main.dart          # App entrypoint — MaterialApp, HomeShell, NavigationBar
├── test/
│   └── widget_test.dart   # Smoke test for tab switching
├── analysis_options.yaml  # Lints (flutter_lints)
├── pubspec.yaml           # Dart/Flutter deps and asset declarations
└── pubspec.lock
```

You will do 95% of your work in `lib/main.dart`. Host-platform folders (`android/`, `ios/`) only need edits for things like app icons, splash screens, signing, or adding native plugins.

---

## First-time setup

From the repo root:

```sh
cd MobileFlutterDemo
flutter pub get
```

This resolves Dart/Flutter packages into `.dart_tool/` and generates platform config. Re-run any time `pubspec.yaml` changes.

List connected devices and running simulators:

```sh
flutter devices
flutter emulators
```

---

## Run on Android emulator (Windows / macOS / Linux)

1. **List available AVDs:**
   ```sh
   flutter emulators
   ```
   If the list is empty, open Android Studio → **Device Manager** → **Create Virtual Device** and pick any recent Pixel image.

2. **Launch an emulator** (substitute the id from the previous command):
   ```sh
   flutter emulators --launch Pixel_6_API_34
   ```
   Or launch it from Android Studio's Device Manager (faster once an image is already downloaded).

3. **Wait** until the emulator finishes booting to the home screen, then confirm:
   ```sh
   flutter devices
   ```

4. **Run the app:**
   ```sh
   flutter run
   ```
   If multiple devices are connected, pass `-d <device-id>`, e.g. `flutter run -d emulator-5554`.

### From Android Studio or VS Code

- **Android Studio:** open the `MobileFlutterDemo` folder → select the emulator in the device dropdown (top toolbar) → press the green **Run** button (▶).
- **VS Code:** open the folder → click the device indicator in the status bar (bottom right) → select your emulator → press **F5** (or Run → Start Debugging).

---

## Run on a physical Android device (Windows)

1. **Enable developer options on the device:**
   - Settings → About phone → tap **Build number** 7 times.
   - Go back → System → **Developer options** → enable **USB debugging**.

2. **Plug the device in via USB.** On the phone, accept the "Allow USB debugging from this computer?" prompt (tick *Always allow*).

3. **Confirm the device is visible:**
   ```sh
   flutter devices
   ```
   If it doesn't show up:
   - On the phone, change USB mode from *Charging only* to *File transfer (MTP)*.
   - `adb kill-server && adb start-server`
   - Verify with `adb devices` — if it says `unauthorized`, re-accept the prompt on the phone.
   - On Windows, some devices need the OEM USB driver (Google USB driver works for most; Samsung/Xiaomi/etc. have their own).

4. **Run:**
   ```sh
   flutter run -d <device-id>
   ```

### Wireless debugging (Android 11+)

Skip the cable after the first pairing:

```sh
# On the phone: Developer options → Wireless debugging → Pair device with pairing code
adb pair <phone-ip>:<pair-port>     # enter the pairing code when prompted
adb connect <phone-ip>:<debug-port>
flutter devices                      # device should appear
flutter run -d <device-id>
```

---

## Run on iOS Simulator (macOS only)

> If you are on Windows, skip this section. The `ios/` folder is already configured; you can open it on a Mac later.

1. Open a Simulator:
   ```sh
   open -a Simulator
   ```
   Or pick one from Xcode → **Open Developer Tool** → **Simulator**.

2. First-time only — install Pods:
   ```sh
   cd ios && pod install && cd ..
   ```

3. Run:
   ```sh
   flutter run
   ```
   Multiple simulators? Use `flutter run -d "iPhone 15 Pro"`.

---

## Run on a physical iPhone (macOS only)

1. Connect the iPhone via USB (or pair wirelessly via Xcode → Window → Devices and Simulators).

2. Open `ios/Runner.xcworkspace` in Xcode (use the workspace, **not** `Runner.xcodeproj`).
   - Select the **Runner** target → **Signing & Capabilities** → pick your **Team**.
   - Xcode will regenerate a bundle identifier if `com.example.mobileFlutterDemo` is taken. Update it to something unique under your team (e.g. `com.yourname.mobileFlutterDemo`).

3. On the iPhone, trust the developer profile: Settings → General → VPN & Device Management → your profile → **Trust**.

4. Run from the command line:
   ```sh
   flutter devices
   flutter run -d <device-id>
   ```
   Or hit ▶ in Xcode with the physical device selected.

---

## Build release artifacts

| Target | Command | Output |
| --- | --- | --- |
| Android APK (universal) | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android App Bundle (Play) | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |
| Android split-per-abi APKs | `flutter build apk --split-per-abi` | per-architecture APKs in same folder |
| iOS (macOS only) | `flutter build ios --release` | `build/ios/iphoneos/Runner.app` — archive & upload via Xcode |

Release Android builds are signed with a debug key by default. For Play Store uploads, set up `android/key.properties` and a keystore — see https://docs.flutter.dev/deployment/android.

---

## Hot reload & hot restart

When `flutter run` is attached:

| Key | What it does |
| --- | --- |
| `r` | Hot reload — pushes changed Dart into the running VM, keeps app state |
| `R` | Hot restart — restarts the app but keeps the device/process |
| `q` | Quit |
| `p` | Toggle debug paint (widget bounds overlay) |
| `o` | Toggle platform (switch between Android & iOS styling at runtime) |
| `h` | Full list of interactive commands |

In VS Code: **Cmd/Ctrl+S** triggers hot reload by default. In Android Studio: the ⚡ icon on the run toolbar.

---

## Troubleshooting

**`flutter` is not recognized**
Your shell doesn't have Flutter on `PATH`. Add `C:\src\flutter\bin` (or wherever you installed it) to your user PATH and open a new terminal.

**`flutter doctor` complains about `cmdline-tools component is missing`**
Open Android Studio → **SDK Manager** → **SDK Tools** tab → check **Android SDK Command-line Tools (latest)** → Apply. Or download https://developer.android.com/studio#command-line-tools-only and extract so the structure is `<SDK>/cmdline-tools/latest/bin/sdkmanager`.

**`Android license status unknown`**
```sh
flutter doctor --android-licenses
```
Then press `y` at every prompt.

**Gradle build hangs or fails with JDK errors**
Flutter uses Android Studio's bundled JDK by default. If it's not picked up:
```sh
flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"
```

**Physical device shows as `unauthorized` in `adb devices`**
On the phone, revoke USB debugging authorizations (Developer options → Revoke USB debugging authorizations), replug, and re-accept the prompt.

**Something weird, no obvious cause**
```sh
flutter clean
flutter pub get
flutter run
```

**Verbose diagnostics**
```sh
flutter doctor -v
flutter run -v
```

---

## Next steps

- Add a new tab: edit the `_tabs` list in `lib/main.dart`. Each tab is a `_TabSpec` with `label`, `icon`, `selectedIcon`, and `body`.
- Add a package: `flutter pub add <package_name>` (e.g. `flutter pub add go_router` for declarative routing).
- Split screens into their own files under `lib/screens/` or `lib/features/` once the app grows beyond one file.
- Run tests: `flutter test`.
- Static analysis: `flutter analyze`.
