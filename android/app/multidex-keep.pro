# Keep Application and Flutter embedding in main dex to fix ClassNotFoundException at startup.
-keep class com.bwh.metal_app.MetalApplication { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class android.app.Application { *; }
