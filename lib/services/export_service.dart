import 'package:get/get.dart';
import 'package:money_flow/services/csv_export_service.dart';
import 'package:money_flow/services/pdf_export_service.dart';

class ExportService extends GetxService {
  final CsvExportService _csvService = Get.find();
  final PdfExportService _pdfService = Get.find();

  Future<void> exportToCSV(DateTime month) async {
    await _csvService.export(month);
  }

  Future<void> exportToPDF(DateTime month) async {
    await _pdfService.export(month);
  }
}