# Google Maps API key setup

Place search in **Create Meetup** uses Google Places when an API key is set; otherwise it uses OpenStreetMap (Nominatim).

## 1. Dart / Places (search)

Pass the key at build/run time so the app can call the Places API:

```bash
flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

For a release build:

```bash
flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

If you don’t set this, place search falls back to Nominatim (no key required).

## 2. Android (map SDK, optional)

If you later add a map widget (e.g. `google_maps_flutter`), the native map needs the key in **Android**:

1. Open `android/local.properties` (create it if needed; it’s gitignored).
2. Add:

   ```properties
   GOOGLE_MAPS_API_KEY=your_key_here
   ```

The app’s `build.gradle` and `AndroidManifest.xml` are already wired to use this value.

## 3. iOS (map SDK, optional)

For the map on **iOS** (when using a map plugin):

1. Open `ios/Runner/Info.plist`.
2. Find the key `GOOGLE_MAPS_API_KEY`.
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key.

## Security

- Do **not** commit your API key. Use `--dart-define` or gitignored files (`local.properties`, etc.).
- Restrict the key in [Google Cloud Console](https://console.cloud.google.com/) (e.g. by app package name / bundle ID and APIs: Places API, and Maps SDK for Android/iOS if you use the map).
