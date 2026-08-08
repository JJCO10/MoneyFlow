import 'package:floor/floor.dart';
import 'package:money_flow/models/transaction_model.dart';

@dao
abstract class TransactionDao {
  @Query('SELECT * FROM Transaction ORDER BY date DESC')
  Future<List<Transaction>> getAllTransactions();
  
  @Query('SELECT * FROM Transaction WHERE date BETWEEN :startDate AND :endDate')
  Future<List<Transaction>> getTransactionsByDate(DateTime startDate, DateTime endDate);
  
  @Query('SELECT * FROM Transaction WHERE categoryId = :categoryId')
  Future<List<Transaction>> getTransactionsByCategory(int categoryId);
  
  @Query('''
    SELECT * FROM Transaction 
    WHERE date BETWEEN :startDate AND :endDate 
    AND type = :type
  ''')
  Future<List<Transaction>> getTransactionsByTypeAndDate(
    String type, DateTime startDate, DateTime endDate
  );
  
  @insert
  Future<void> insertTransaction(Transaction transaction);
  
  @update
  Future<void> updateTransaction(Transaction transaction);
  
  @delete
  Future<void> deleteTransaction(Transaction transaction);
}