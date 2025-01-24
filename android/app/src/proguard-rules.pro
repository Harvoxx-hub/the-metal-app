# Keep all Zego-related classes
-keep class **.zego.** { *; }

# Stripe Push Provisioning rules (existing in your configuration)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Heytap Push SDK rules
-keep class com.heytap.msp.** { *; }
-dontwarn com.heytap.msp.**

# ZPNs internal client rules (referenced in the error message)
-keep class im.zego.zpns.** { *; }
-dontwarn im.zego.zpns.**

# General ProGuard rules for reflection-based libraries
-keepclassmembers class * {
    public <init>(...);
}

# Optional: Keep annotations (useful for SDKs relying on annotations for configuration)
-keep @interface **

# Optional: Prevent obfuscation of model classes (useful for JSON serialization)
-keep class com.your.package.model.** { *; }
