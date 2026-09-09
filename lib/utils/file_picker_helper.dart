import 'dart:io';
import 'package:file_selector/file_selector.dart';

class FilePickerHelper {
  static Future<File?> pickJsonFile() async {
    try {
      final typeGroup = XTypeGroup(
        label: 'JSON',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );
      
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return null;
      return File(file.path);
    } catch (e) {
      print('❌ Error seleccionando archivo: $e');
      return null;
    }
  }
}