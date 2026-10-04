# ==================== FLUTTER ====================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ==================== SQLITE ====================
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# ==================== MODELOS DE LA APP ====================
-keep class com.example.money_flow.models.** { *; }

# ==================== GETX ====================
-keep class com.getx.** { *; }

# ==================== NOTIFICACIONES ====================
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# ==================== PATH PROVIDER ====================
-keep class io.flutter.plugins.pathprovider.** { *; }

# ==================== SHARED PREFERENCES ====================
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ==================== FILE PROVIDER ====================
-keep class androidx.core.content.FileProvider { *; }

# ==================== PDF ====================
-keep class com.tom_roush.pdfbox.** { *; }

# ==================== GSON (si usas JSON) ====================
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# ==================== MANTENER CLASES DE FLUTTER ====================
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# ==================== EVITAR ADVERTENCIAS ====================
-dontwarn io.flutter.embedding.**
-dontwarn org.sqlite.**
-dontwarn com.google.gson.**