# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.embedding.**

# Kakao SDK (login, share, etc.)
-keep class com.kakao.sdk.**.model.* { <fields>; }
-keep class * extends com.google.gson.TypeAdapter
-keepattributes Signature
-keepattributes *Annotation*

# Kakao Map
-keep class com.kakao.vectormap.** { *; }
-keep class net.daum.** { *; }
-dontwarn com.kakao.vectormap.**

# Naver Login SDK
-keep class com.navercorp.nid.** { *; }
-dontwarn com.navercorp.nid.**
-keep class com.nhn.android.naverlogin.** { *; }
-dontwarn com.nhn.android.naverlogin.**

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson / reflection based JSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# OkHttp (used by Dio transitively on some configs)
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep enum values
-keepclassmembers enum * { *; }
