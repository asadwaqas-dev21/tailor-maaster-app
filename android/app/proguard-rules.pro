# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core (referenced by Flutter for deferred components, not used)
-dontwarn com.google.android.play.core.**

# Hive
-keep class ** extends com.google.protobuf.GeneratedMessageLite { *; }

# Google Fonts (uses network)
-dontwarn okhttp3.**
-dontwarn okio.**

# Mailer (SMTP)
-dontwarn javax.mail.**
-dontwarn com.sun.mail.**
-keep class javax.mail.** { *; }

# General
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-dontwarn java.lang.invoke.**
