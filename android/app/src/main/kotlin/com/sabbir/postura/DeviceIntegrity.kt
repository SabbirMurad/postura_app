package com.sabbir.postura

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.File

/// On-device root check. These are deterrents, not a guarantee:
/// a determined attacker can hide root, and Google's
/// Play Integrity attestation isn't available to an app installed from the web.
/// The backend validates everything it receives regardless.
object DeviceIntegrity {

    private val SU_PATHS = listOf(
        "/system/bin/su", "/system/xbin/su", "/sbin/su", "/system/su",
        "/su/bin/su", "/data/local/xbin/su", "/data/local/bin/su", "/data/local/su",
        "/system/sd/xbin/su", "/system/bin/failsafe/su", "/debug_ramdisk/su",
        "/system/app/Superuser.apk",
    )

    // Also listed under <queries> in AndroidManifest.xml, which Android 11+
    // needs before it will say whether they're installed.
    private val ROOT_APPS = listOf(
        "com.topjohnwu.magisk", "eu.chainfire.supersu", "com.koushikdutta.superuser",
        "com.noshufou.android.su", "com.kingroot.kinguser", "com.thirdparty.superuser",
    )

    fun isRooted(context: Context): Boolean {
        if (Build.TAGS?.contains("test-keys") == true) return true
        if (SU_PATHS.any { File(it).exists() }) return true
        val pm = context.packageManager
        return ROOT_APPS.any { pkg ->
            try {
                pm.getPackageInfo(pkg, 0)
                true
            } catch (_: PackageManager.NameNotFoundException) {
                false
            }
        }
    }

    fun check(context: Context): Map<String, Boolean> =
        mapOf("rooted" to isRooted(context))
}
