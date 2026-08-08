import 'package:floor/floor.dart';
import 'package:money_flow/models/transaction_model.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM transactions ORDER BY date DESC')
  Future<List<Transaction>> getAllTransactions();
  
  @Query('SELECT * FROM transactions WHERE date BETWEEN :startTimestamp AND :endTimestamp')
  Future<List<Transaction>> getTransactionsBetween(int startTimestamp, int endTimestamp);
  
  @Query('SELECT * FROM transactions WHERE categoryId = :categoryId')
  Future<List<Transaction>> getTransactionsByCategory(int categoryId);
  
  @Query('''
    SELECT * FROM transactions 
    WHERE date BETWEEN :startTimestamp AND :endTimestamp 
    AND type = :type
  ''')
  Future<List<Transaction>> getTransactionsByTypeAndDate(
    String type, 
    int startTimestamp, 
    int endTimestamp
  );
  
  @Query('''
    SELECT SUM(amount) FROM transactions 
    WHERE type = :type AND date BETWEEN :startTimestamp AND :endTimestamp
  ''')
  Future<double?> getSumByTypeAndDate(
    String type, 
    int startTimestamp, 
    int endTimestamp
  );
  
  @insert
  Future<void> insertTransaction(Transaction transaction);
  
  @update
  Future<void> updateTransaction(Transaction transaction);
  
  @delete
  Future<void> deleteTransaction(Transaction transaction);
}