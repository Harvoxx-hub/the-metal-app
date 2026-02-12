package com.bwh.metal_app

import android.app.Application
import android.content.Context
import androidx.multidex.MultiDex

/**
 * Custom Application in the app package so it is in the main dex.
 * Extends Application directly (Flutter embedding v2 handles engine init via FlutterActivity).
 * Calls MultiDex.install() before super so all dex files are loaded as early as possible.
 */
class MetalApplication : Application() {

    override fun attachBaseContext(base: Context) {
        MultiDex.install(base)
        super.attachBaseContext(base)
    }
}
