// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CategoryDao? _categoryDaoInstance;

  TransactionDao? _transactionDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `categories` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `type` TEXT NOT NULL, `icon` TEXT NOT NULL, `color` INTEGER NOT NULL, `isDefault` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `transactions` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `amount` REAL NOT NULL, `type` TEXT NOT NULL, `categoryId` INTEGER NOT NULL, `description` TEXT NOT NULL, `date` INTEGER NOT NULL, `isRecurring` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CategoryDao get categoryDao {
    return _categoryDaoInstance ??= _$CategoryDao(database, changeListener);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$TransactionDao(database, changeListener);
  }
}

class _$CategoryDao extends CategoryDao {
  _$CategoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _categoryInsertionAdapter = InsertionAdapter(
            database,
            'categories',
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'icon': item.icon,
                  'color': item.color,
                  'isDefault': item.isDefault ? 1 : 0
                }),
        _categoryUpdateAdapter = UpdateAdapter(
            database,
            'categories',
            ['id'],
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'icon': item.icon,
                  'color': item.color,
                  'isDefault': item.isDefault ? 1 : 0
                }),
        _categoryDeletionAdapter = DeletionAdapter(
            database,
            'categories',
            ['id'],
            (Category item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'type': item.type,
                  'icon': item.icon,
                  'color': item.color,
                  'isDefault': item.isDefault ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Category> _categoryInsertionAdapter;

  final UpdateAdapter<Category> _categoryUpdateAdapter;

  final DeletionAdapter<Category> _categoryDeletionAdapter;

  @override
  Future<List<Category>> getAllCategories() async {
    return _queryAdapter.queryList('SELECT * FROM categories ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Category(
            id: row['id'] as int?,
            name: row['name'] as String,
            type: row['type'] as String,
            icon: row['icon'] as String,
            color: row['color'] as int,
            isDefault: (row['isDefault'] as int) != 0));
  }

  @override
  Future<List<Category>> getCategoriesByType(String type) async {
    return _queryAdapter.queryList('SELECT * FROM categories WHERE type = ?1',
        mapper: (Map<String, Object?> row) => Category(
            id: row['id'] as int?,
            name: row['name'] as String,
            type: row['type'] as String,
            icon: row['icon'] as String,
            color: row['color'] as int,
            isDefault: (row['isDefault'] as int) != 0),
        arguments: [type]);
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    return _queryAdapter.query('SELECT * FROM categories WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Category(
            id: row['id'] as int?,
            name: row['name'] as String,
            type: row['type'] as String,
            icon: row['icon'] as String,
            color: row['color'] as int,
            isDefault: (row['isDefault'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<void> insertCategory(Category category) async {
    await _categoryInsertionAdapter.insert(category, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _categoryUpdateAdapter.update(category, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCategory(Category category) async {
    await _categoryDeletionAdapter.delete(category);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _transactionInsertionAdapter = InsertionAdapter(
            database,
            'transactions',
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'amount': item.amount,
                  'type': item.type,
                  'categoryId': item.categoryId,
                  'description': item.description,
                  'date': item.dateTimestamp,
                  'isRecurring': item.isRecurring ? 1 : 0
                }),
        _transactionUpdateAdapter = UpdateAdapter(
            database,
            'transactions',
            ['id'],
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'amount': item.amount,
                  'type': item.type,
                  'categoryId': item.categoryId,
                  'description': item.description,
                  'date': item.dateTimestamp,
                  'isRecurring': item.isRecurring ? 1 : 0
                }),
        _transactionDeletionAdapter = DeletionAdapter(
            database,
            'transactions',
            ['id'],
            (Transaction item) => <String, Object?>{
                  'id': item.id,
                  'amount': item.amount,
                  'type': item.type,
                  'categoryId': item.categoryId,
                  'description': item.description,
                  'date': item.dateTimestamp,
                  'isRecurring': item.isRecurring ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Transaction> _transactionInsertionAdapter;

  final UpdateAdapter<Transaction> _transactionUpdateAdapter;

  final DeletionAdapter<Transaction> _transactionDeletionAdapter;

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            amount: row['amount'] as double,
            type: row['type'] as String,
            categoryId: row['categoryId'] as int,
            description: row['description'] as String,
            isRecurring: (row['isRecurring'] as int) != 0));
  }

  @override
  Future<List<Transaction>> getTransactionsBetween(
    int startTimestamp,
    int endTimestamp,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions WHERE date BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            amount: row['amount'] as double,
            type: row['type'] as String,
            categoryId: row['categoryId'] as int,
            description: row['description'] as String,
            isRecurring: (row['isRecurring'] as int) != 0),
        arguments: [startTimestamp, endTimestamp]);
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions WHERE categoryId = ?1',
        mapper: (Map<String, Object?> row) => Transaction(
            id: row['id'] as int?,
            amount: row['amount'] as double,
            type: row['type'] as String,
            categoryId: row['categoryId'] as int,
            description: row['description'] as String,
            isRecurring: (row['isRecurring'] as int) != 0),
        arguments: [categoryId]);
  }

  @override
  Future<List<Transaction>> getTransactionsByTypeAndDate(
    String type,
    int startTimestamp,
    int endTimestamp,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transactions      WHERE date BETWEEN ?2 AND ?3      AND type = ?1',
        mapper: (Map<String, Object?> row) => Transaction(id: row['id'] as int?, amount: row['amount'] as double, type: row['type'] as String, categoryId: row['categoryId'] as int, description: row['description'] as String, isRecurring: (row['isRecurring'] as int) != 0),
        arguments: [type, startTimestamp, endTimestamp]);
  }

  @override
  Future<double?> getSumByTypeAndDate(
    String type,
    int startTimestamp,
    int endTimestamp,
  ) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM transactions      WHERE type = ?1 AND date BETWEEN ?2 AND ?3',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [type, startTimestamp, endTimestamp]);
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    await _transactionInsertionAdapter.insert(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionUpdateAdapter.update(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionDeletionAdapter.delete(transaction);
  }
}
