# Keep all Zego-related classes
-keep class **.zego.** { *; }

# Stripe Push Provisioning rules
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Keep rules for suppressing warnings from Heytap, Huawei, Vivo, and Xiaomi push services
-dontwarn com.heytap.msp.push.HeytapPushManager
-dontwarn com.heytap.msp.push.callback.ICallBackResultService
-dontwarn com.heytap.msp.push.mode.DataMessage
-dontwarn com.heytap.msp.push.service.DataMessageCallbackService
-dontwarn com.huawei.hms.aaid.HmsInstanceId
-dontwarn com.huawei.hms.common.ApiException
-dontwarn com.huawei.hms.push.HmsMessageService
-dontwarn com.huawei.hms.push.RemoteMessage$Notification
-dontwarn com.huawei.hms.push.RemoteMessage
-dontwarn com.vivo.push.IPushActionListener
-dontwarn com.vivo.push.PushClient
-dontwarn com.vivo.push.PushConfig$Builder
-dontwarn com.vivo.push.PushConfig
-dontwarn com.vivo.push.listener.IPushQueryActionListener
-dontwarn com.vivo.push.model.UPSNotificationMessage
-dontwarn com.vivo.push.model.UnvarnishedMessage
-dontwarn com.vivo.push.sdk.OpenClientPushMessageReceiver
-dontwarn com.vivo.push.util.VivoPushException
-dontwarn com.xiaomi.mipush.sdk.MiPushClient
-dontwarn com.xiaomi.mipush.sdk.MiPushCommandMessage
-dontwarn com.xiaomi.mipush.sdk.MiPushMessage
-dontwarn com.xiaomi.mipush.sdk.PushMessageReceiver
-dontwarn java.beans.ConstructorProperties
-dontwarn java.beans.Transient
-dontwarn org.w3c.dom.bootstrap.DOMImplementationRegistry

# Keep classes and members from obfuscation related to the push services
-keep class com.heytap.msp.push.** { *; }
-keep class com.huawei.hms.** { *; }
-keep class com.vivo.push.** { *; }
-keep class com.xiaomi.mipush.sdk.** { *; }

# Additional configurations (if required by your app or third-party libraries)
-keepattributes Signature
-keepattributes *Annotation*
-keep class javax.** { *; }
-keepnames class javax.** { *; }
-keepnames class kotlin.Metadata { *; }
-dontwarn kotlin.**

# General ProGuard rules for reflection-based libraries
-keepclassmembers class * {
    public <init>(...);
}

 