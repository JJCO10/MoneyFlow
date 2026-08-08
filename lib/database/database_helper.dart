import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:money_flow/models/category_model.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/database/daos/category_dao.dart';
import 'package:money_flow/database/daos/transaction_dao.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Category, Transaction])
abstract class AppDatabase extends FloorDatabase {
  CategoryDao get categoryDao;
  TransactionDao get transactionDao;
}