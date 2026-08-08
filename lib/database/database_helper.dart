import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _initialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!_initialized) {
      try {
        if (kIsWeb) {
          // Para WEB: usar sqflite_common_ffi_web
          print('🌐 Inicializando sqflite para Web...');
          databaseFactory = databaseFactoryFfiWeb;
          print('✅ sqflite inicializado para Web');
        } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // Para Desktop: usar sqflite_common_ffi
          print('💻 Inicializando sqflite para Desktop...');
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          print('✅ sqflite inicializado para Desktop');
        }
        _initialized = true;
      } catch (e) {
        print('⚠️ Error inicializando sqflite: $e');
        // Si falla, intentar con la configuración por defecto
        print('🔄 Intentando con configuración por defecto...');
      }
    }

    // Obtener la ruta de la base de datos
    String dbPath;
    
    try {
      if (kIsWeb) {
        // En WEB: usar un nombre simple
        dbPath = 'moneyflow.db';
        print('📁 Ruta DB Web: $dbPath (IndexedDB)');
      } else {
        // En MÓVIL/DESKTOP: usar el sistema de archivos
        try {
          final directory = await getApplicationDocumentsDirectory();
          dbPath = join(directory.path, 'moneyflow.db');
          print('📁 Ruta DB Nativa: $dbPath');
        } catch (e) {
          final databasesPath = await getDatabasesPath();
          dbPath = join(databasesPath, 'moneyflow.db');
          print('📁 Ruta DB Fallback: $dbPath');
        }
      }
    } catch (e) {
      print('⚠️ Error obteniendo ruta: $e');
      dbPath = 'moneyflow.db';
    }

    try {
      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('❌ Error abriendo base de datos: $e');
      // Si falla, intentar con una base de datos en memoria
      print('🔄 Intentando con base de datos en memoria...');
      return await openDatabase(
        'memory.db',
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Crear tabla de categorías
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon TEXT NOT NULL,
          color INTEGER NOT NULL,
          isDefault INTEGER NOT NULL
        )
      ''');

      // Crear tabla de transacciones
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          categoryId INTEGER NOT NULL,
          description TEXT NOT NULL,
          date INTEGER NOT NULL,
          isRecurring INTEGER NOT NULL,
          FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
        )
      ''');

      // Insertar categorías por defecto
      final defaultCategories = [
        // Gastos
        Category(name: 'Alimentación', type: 'expense', icon: '🍽️', color: 0xFFEF4444, isDefault: true),
        Category(name: 'Transporte', type: 'expense', icon: '🚗', color: 0xFF3B82F6, isDefault: true),
        Category(name: 'Compras', type: 'expense', icon: '🛍️', color: 0xFF8B5CF6, isDefault: true),
        Category(name: 'Salud', type: 'expense', icon: '🏥', color: 0xFF10B981, isDefault: true),
        Category(name: 'Educación', type: 'expense', icon: '📚', color: 0xFFF59E0B, isDefault: true),
        Category(name: 'Entretenimiento', type: 'expense', icon: '🎬', color: 0xFFEC4899, isDefault: true),
        Category(name: 'Hogar', type: 'expense', icon: '🏠', color: 0xFF14B8A6, isDefault: true),
        
        // Ingresos
        Category(name: 'Salario', type: 'income', icon: '💰', color: 0xFF10B981, isDefault: true),
        Category(name: 'Freelance', type: 'income', icon: '💻', color: 0xFF3B82F6, isDefault: true),
        Category(name: 'Inversiones', type: 'income', icon: '📈', color: 0xFF8B5CF6, isDefault: true),
      ];

      for (var category in defaultCategories) {
        await db.insert('categories', category.toMap());
      }
      
      print('✅ Base de datos creada con categorías por defecto');
    } catch (e) {
      print('❌ Error creando tablas: $e');
      rethrow;
    }
  }

  // ==================== MÉTODOS DE CATEGORÍAS ====================
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Category.fromMap(result.first);
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MÉTODOS DE TRANSACCIONES ====================
  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsBetween(DateTime start, DateTime end) async {
    final db = await database;
    final startTimestamp = DateTime(start.year, start.month, start.day).millisecondsSinceEpoch;
    final endTimestamp = DateTime(end.year, end.month, end.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'date DESC',
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<double> getSumByTypeAndDate(String type, DateTime start, DateTime end) async {
    final db = await database;
    final startTimestamp = DateTime(start.year, start.month, start.day).millisecondsSinceEpoch;
    final endTimestamp = DateTime(end.year, end.month, end.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date BETWEEN ? AND ?',
      [type, startTimestamp, endTimestamp],
    );
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}