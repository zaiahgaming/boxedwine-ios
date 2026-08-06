# Boxedwine iOS Game Launcher & Optimizer

This workspace contains an iOS wrapper and configuration setup for [Boxedwine](https://github.com/danoon2/Boxedwine) to run 32-bit Windows applications and games on iOS with maximum hardware resource allocation.

## Key Features & Max Performance Optimizations

1. **iOS Game Category Optimization (`LSApplicationCategoryType = public.app-category.games`)**:
   - Forces iOS (especially iOS 18+ Game Mode) to recognize Boxedwine as a high-priority game application.
   - Prevents iOS CPU/GPU throttling, elevates process scheduling priority, and allows maximum sustained thermal thresholds.
2. **GameController Framework Support**:
   - Declares `GCSupportsGameControllers = true` allowing extended hardware controller integration (MFi, DualSense, Xbox controllers).
3. **120Hz ProMotion Display Support**:
   - `CADisableMinimumFrameDurationOnPhone` set to `true` to uncap iOS frame rendering limits.
4. **Low-Latency Game Audio Session**:
   - `AppMain.m` initializes `AVAudioSessionModeGameChat` with a 5ms IO buffer (`0.005s`), preventing audio stuttering and eliminating audio pipeline latency.
5. **JIT & Extended Addressing Entitlements**:
   - Includes `dynamic-codesigning` and `get-task-allow` entitlements for high performance x86 CPU dynamic translation.

## Folder Structure

```
boxedwine-ios/
├── setup_boxedwine_ios.sh      # Setup script to check & sync Boxedwine source
├── Boxedwine/                  # Cloned danoon2/Boxedwine repository
└── iOS/
    ├── Info.plist              # Bundle config specifying Game category & resource options
    ├── BoxedwineApp.entitlements # Entitlements for JIT & memory expansion
    └── AppMain.m               # Objective-C entrypoint for Game Audio session & application initialization
```

## How to Build for iOS

1. Run the setup script:
   ```bash
   ./setup_boxedwine_ios.sh
   ```
2. Build the project using CMake for Xcode iOS target:
   ```bash
   mkdir -p build-ios
   cd build-ios
   cmake -G Xcode -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 ..
   ```
3. Open the generated `.xcodeproj` in Xcode, connect an iOS device, select your signing team, and run on device.
