# Debugging "Metal keeps stopping" on Android

If the app crashes on Android but works on iOS, capture the crash log to find the cause.

## Capture crash log

1. Connect your Android device via USB and enable USB debugging.
2. Clear logcat, then launch Metal on the device:
   ```bash
   adb logcat -c && adb shell am start -n com.bwh.metal_app.dev/.MainActivity
   ```
   (Use `com.bwh.metal_app/.MainActivity` for prod flavor.)
3. When the app crashes, run:
   ```bash
   adb logcat -d | grep -E "FATAL|AndroidRuntime|Exception|flutter|com.bwh.metal"
   ```
4. Look for `FATAL EXCEPTION` and the stack trace (lines after "Caused by:").

## Common causes

- **Firebase Remote Config** – Now guarded in `main.dart`; app continues if it fails.
- **Shorebird** – Debug builds from `flutter run` are not Shorebird releases; install a Shorebird release with `shorebird release android --flavor dev` if you need to test OTA.
- **Native crash** – The logcat stack trace will show the failing Java/Kotlin class.

## Run with device selected

```bash
flutter run --flavor dev -d <device_id>
```

List devices: `flutter devices`
