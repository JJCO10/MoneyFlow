import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static String? _cachedPackageName;

  /// Obtiene el applicationId real de la app en tiempo de ejecución.
  /// Se cachea después de la primera llamada.
  static Future<String> getPackageName() async {
    if (_cachedPackageName != null) {
      return _cachedPackageName!;
    }
    final info = await PackageInfo.fromPlatform();
    _cachedPackageName = info.packageName;
    return _cachedPackageName!;
  }
}