import 'package:flutter/services.dart';

class FileShareChannel {
  static const MethodChannel _channel = MethodChannel('com.moneyflow/file_share');

  static Future<bool> shareFile(String filePath, String mimeType) async {
    try {
      final result = await _channel.invokeMethod('shareFile', {
        'filePath': filePath,
        'mimeType': mimeType,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('❌ Error en canal nativo: ${e.message}');
      return false;
    }
  }
}