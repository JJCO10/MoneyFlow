import 'package:flutter/material.dart';
import 'app.dart';
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/services/category_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await Get.putAsync(() => CategoryService().init());
  await Get.putAsync(() => TransactionService().init());
  
  runApp(const App());
}