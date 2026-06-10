# Flutter UI Notes

## UI Design Systems

Flutter ships with two design systems built in:

- **Material** (`flutter/material.dart`) — Google's Material Design. The default and most battle-tested. Most production apps use this on both Android and iOS.
- **Cupertino** (`flutter/cupertino.dart`) — Apple's iOS design language. Built into Flutter, no package needed.

Community alternatives:
- `fluent_ui` — Microsoft Fluent Design, popular for Windows desktop targets
- `shadcn_ui` — port of shadcn for Flutter

### Platform-Adaptive UI (toggling Material vs Cupertino per platform)

Possible but uncommon in practice. Flutter provides a handful of `.adaptive` constructors (`Switch.adaptive`, `Slider.adaptive`, etc.) that automatically use the platform-appropriate widget — that's the lowest-effort version.

A full toggle (different widget tree per platform) roughly doubles UI code and most teams skip it because:
- iOS users are accustomed to Material apps — Google's own apps (Gmail, Maps, Drive) use Material on iOS
- The App Store doesn't reject apps for using Material

Teams that do go fully adaptive typically have a strong "native feel" requirement for a consumer-facing iOS audience.

---

## Sizing Units: Logical Pixels

Flutter's sizing unit is the **logical pixel** — similar to CSS `px`. The runtime multiplies it by the device pixel ratio automatically, so `height: 160` appears the same physical size on a 2x and 3x density screen.

This is **not** like CSS `rem`, which scales with screen size.

### Why hard-coded logical pixels are fine on phones

Phone screen widths only vary from roughly 360–430 logical pixels. A value like `height: 160` works across that range in a way it wouldn't on the web (320px to 2560px). Hard-coded logical pixels are the **dominant production approach for phone-only apps**.

### Where it breaks down

Tablets and foldables have much more screen size variance. That's where alternative approaches become necessary.

### Responsive sizing options

| Approach | Use case |
|---|---|
| Hard-coded logical pixels | Phone-only apps — standard and fine |
| `Flexible` / `Expanded` in Row/Column | Proportional flex layout — always used, even in phone-only apps |
| `flutter_screenutil` package | Define a reference resolution; values scale proportionally to actual screen. Closest Flutter equivalent to CSS `rem`. Common for tablet/foldable support. |
| `MediaQuery.of(context).size` | Read actual screen dimensions at runtime and compute fractions manually |
| `FractionallySizedBox` | Size a child as a fraction of its parent |

### Text scaling

Flutter automatically respects the OS accessibility text size setting via `TextScaler`. Text already scales without extra work — similar to how `rem`-based text scales with the browser's root font size.

### Summary

| Scenario | Common approach |
|---|---|
| Phone-only app | Hard-coded logical pixels + `Flexible`/`Expanded` |
| Tablet or foldable support | `flutter_screenutil` or `MediaQuery`-derived sizing |
| Text sizing | Handled automatically by Flutter via OS accessibility settings |
