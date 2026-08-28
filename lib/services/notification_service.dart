import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:get/get.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:intl/intl.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final TransactionService _transactionService = Get.find();
  
  // 🔥 Para evitar múltiples programaciones
  bool _isScheduled = false;

  Future<NotificationService> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    return this;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      switch (response.payload) {
        case 'home':
          Get.offAllNamed('/');
          break;
        case 'budgets':
          Get.offAllNamed('/budgets');
          break;
        default:
          Get.offAllNamed('/');
      }
    }
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> checkPermissions() async {
    return await Permission.notification.isGranted;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'moneyflow_channel',
      'MoneyFlow',
      channelDescription: 'Notificaciones de MoneyFlow',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      const androidDetails = AndroidNotificationDetails(
        'moneyflow_channel',
        'MoneyFlow',
        channelDescription: 'Notificaciones programadas de MoneyFlow',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: false,
      );
      
      print('✅ Notificación programada para: $scheduledTime');
      _isScheduled = true;
      
    } catch (e) {
      print('⚠️ Error programando notificación: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    if (id == 999) {
      _isScheduled = false;
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _isScheduled = false;
  }

  // ==================== RESUMEN DIARIO ====================
  Future<void> scheduleDailySummaryIfEnabled() async {
    // 🔥 SOLO PROGRAMAR SI NO ESTÁ YA PROGRAMADA
    if (_isScheduled) {
      print('📊 El resumen diario ya está programado');
      return;
    }

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    final finalTime = scheduledTime.isAfter(now)
        ? scheduledTime
        : scheduledTime.add(const Duration(days: 1));

    final summary = await _getDailySummary();

    await scheduleNotification(
      id: 999,
      title: '📊 Resumen del Día',
      body: summary,
      scheduledTime: finalTime,
      payload: 'home',
    );
    
    print('📊 Resumen diario programado para las 9:00 PM');
  }

  Future<String> _getDailySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final transactions = await _transactionService.getTransactionsBetween(
      startOfDay,
      endOfDay,
    );

    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    if (transactions.isEmpty) {
      return 'Hoy no has registrado movimientos en tu cuenta.';
    }

    return '💰 Ingresos: \$${totalIncome.toStringAsFixed(2)}\n'
           '💳 Gastos: \$${totalExpense.toStringAsFixed(2)}\n'
           '📊 Balance: \$${balance.toStringAsFixed(2)}\n'
           '📋 Total movimientos: ${transactions.length}';
  }

  // ==================== ALERTA DE PRESUPUESTO ====================
  Future<void> sendBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
  }) async {
    final percentage = (spent / limit * 100).toStringAsFixed(0);
    final remaining = (limit - spent).toStringAsFixed(2);

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '⚠️ Alerta de Presupuesto',
      body: 'Has gastado el $percentage% del presupuesto de $categoryName. '
            'Restante: \$$remaining',
      payload: 'budgets',
    );
  }
}