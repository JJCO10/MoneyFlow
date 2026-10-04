import 'package:get/get.dart';
import 'package:money_flow/database/database_helper.dart';
import 'package:money_flow/services/transaction_service.dart';
import 'package:money_flow/models/transaction_model.dart';

class RecurrenceService extends GetxService {
  final TransactionService _transactionService = Get.find();
  final DatabaseHelper _db = DatabaseHelper();

  // 🔥 VERIFICAR Y GENERAR TRANSACCIONES PENDIENTES
  Future<void> processRecurringTransactions() async {
    try {
      print('🔄 Procesando transacciones recurrentes pendientes...');

      // Obtener todas las transacciones recurrentes (padres)
      final recurringTransactions =
          await _transactionService.getRecurringTransactions();

      if (recurringTransactions.isEmpty) {
        print('✅ No hay transacciones recurrentes');
        return;
      }

      print(
          '📊 Encontradas ${recurringTransactions.length} transacciones recurrentes');

      final now = DateTime.now();
      int totalGenerated = 0;

      for (var parent in recurringTransactions) {
        final generated = await _generatePendingTransactions(parent, now);
        totalGenerated += generated;
      }

      if (totalGenerated > 0) {
        print('✅ Se generaron $totalGenerated transacciones pendientes');
      } else {
        print('✅ No hay transacciones pendientes por generar');
      }
    } catch (e) {
      print('❌ Error procesando recurrentes: $e');
    }
  }

  // 🔥 GENERAR TODAS LAS TRANSACCIONES FALTANTES (PASADAS Y FUTURAS HASTA HOY)
  Future<int> _generatePendingTransactions(
      Transaction parent, DateTime now) async {
    if (parent.id == null) return 0;
    if (parent.recurrenceType == null) return 0;

    // Obtener las hijas existentes
    final children = await _transactionService.getChildTransactions(parent.id!);

    // 🔥 CREAR UN SET DE FECHAS YA GENERADAS (solo el día, sin hora)
    final existingDates = <String>{};
    for (var child in children) {
      final dateKey =
          '${child.date.year}-${child.date.month}-${child.date.day}';
      existingDates.add(dateKey);
    }

    // 🔥 OBTENER LAS FECHAS ELIMINADAS MANUALMENTE
    final deletedDates = await _db.getDeletedDates(parent.id!);
    final deletedDatesSet = <String>{};
    for (var deletedDate in deletedDates) {
      final dateKey =
          '${deletedDate.year}-${deletedDate.month}-${deletedDate.day}';
      deletedDatesSet.add(dateKey);
    }

    print('📅 Fechas ya generadas: ${existingDates.length}');
    print('🗑️ Fechas eliminadas manualmente: ${deletedDatesSet.length}');

    // 🔥 CALCULAR FECHA DE FIN
    final endDate = parent.recurrenceEnd ??
        DateTime(parent.date.year, parent.date.month + 1, parent.date.day);

    print('📅 Fecha inicio: ${parent.date}');
    print('📅 Fecha fin: $endDate');
    print('📅 Fecha actual: $now');

    // 🔥 CALCULAR LÍMITE: HOY O FECHA DE FIN (el que sea menor)
    final limitDate = now.isBefore(endDate) ? now : endDate;

    // 🔥 EMPEZAR DESDE LA FECHA DEL PADRE Y GENERAR TODAS LAS FALTANTES
    DateTime currentDate = parent.date;
    int count = 0;

    // Iterar desde la fecha del padre hasta el límite
    while (currentDate.isBefore(limitDate) ||
        currentDate.isAtSameMomentAs(limitDate)) {
      // 🔥 SALTAR LA FECHA DEL PADRE (ya existe)
      if (!currentDate.isAtSameMomentAs(parent.date)) {
        final dateKey =
            '${currentDate.year}-${currentDate.month}-${currentDate.day}';

        // 🔥 SOLO GENERAR SI NO EXISTE Y NO ESTÁ EN LA LISTA DE ELIMINADAS
        if (!existingDates.contains(dateKey) &&
            !deletedDatesSet.contains(dateKey)) {
          final transaction = Transaction(
            amount: parent.amount,
            type: parent.type,
            categoryId: parent.categoryId,
            description: parent.description,
            date: currentDate,
            isRecurring: false,
            parentId: parent.id,
          );

          await _transactionService.saveTransaction(transaction);
          existingDates.add(dateKey);
          count++;
        }
      }

      // Avanzar a la siguiente fecha
      currentDate = _getNextDate(currentDate, parent.recurrenceType!);

      // Seguridad: máximo 365 iteraciones
      if (count >= 365) break;
    }

    if (count > 0) {
      print('   ✅ ${parent.description}: $count transacciones generadas');
    } else {
      print('   ℹ️ ${parent.description}: ya está actualizado');
    }

    return count;
  }

  // 🔥 CALCULAR LA SIGUIENTE FECHA
  DateTime _getNextDate(DateTime currentDate, String recurrenceType) {
    switch (recurrenceType) {
      case 'daily':
        return currentDate.add(const Duration(days: 1));
      case 'weekly':
        return currentDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
            currentDate.year, currentDate.month + 1, currentDate.day);
      case 'yearly':
        return DateTime(
            currentDate.year + 1, currentDate.month, currentDate.day);
      default:
        return currentDate.add(const Duration(days: 1));
    }
  }
}
