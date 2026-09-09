import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FileShareChannel {
  static const MethodChannel _channel = MethodChannel('com.moneyflow/file_share');

  static Future<bool> shareFile(String filePath, String mimeType) async {
    try {
      // Para Android, asegurar que la ruta es accesible
      if (Platform.isAndroid) {
        final file = File(filePath);
        if (!await file.exists()) {
          print('❌ El archivo no existe: $filePath');
          return false;
        }
      }
      
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