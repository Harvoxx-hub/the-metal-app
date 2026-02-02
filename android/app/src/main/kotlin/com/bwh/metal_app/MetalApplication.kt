package com.bwh.metal_app

import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication

/**
 * Custom Application in the app package so it is in the main dex.
 * Fixes ClassNotFoundException when FlutterApplication ends up in a secondary dex.
 * Uses v1 FlutterApplication (from engine JAR) so Kotlin can resolve it at compile time.
 * Calls MultiDex.install() before super so all dex files are loaded as early as possible.
 */
class MetalApplication : FlutterApplication() {

    override fun attachBaseContext(base: Context) {
        MultiDex.install(base)
        super.attachBaseContext(base)
    }
}
