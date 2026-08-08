import 'package:get/get.dart';
import 'package:money_flow/database/database.dart';
import 'package:money_flow/models/transaction_model.dart';
import 'package:money_flow/database/daos/transaction_dao.dart';

class TransactionService extends GetxService {
  late TransactionDao _transactionDao;
  
  Future<TransactionService> init() async {
    final database = await $FloorAppDatabase.databaseBuilder('moneyflow.db').build();
    _transactionDao = database.transactionDao;
    return this;
  }
  
  Future<List<Transaction>> getAllTransactions() async {
    return await _transactionDao.getAllTransactions();
  }
  
  Future<List<Transaction>> getTransactionsBetween(DateTime start, DateTime end) async {
    return await _transactionDao.getTransactionsByDate(start, end);
  }
  
  Future<void> saveTransaction(Transaction transaction) async {
    await _transactionDao.insertTransaction(transaction);
  }
  
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionDao.updateTransaction(transaction);
  }
  
  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionDao.deleteTransaction(transaction);
  }
}