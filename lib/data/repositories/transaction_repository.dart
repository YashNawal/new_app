import 'package:borrow_manager/data/models/transaction.dart';
import 'package:borrow_manager/data/sources/local/database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> addTransaction(Transaction transaction) async {
    await _databaseHelper.insertTransaction(transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseHelper.updateTransaction(transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.queryAllTransactions();
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(String id) async {
    final map = await _databaseHelper.queryTransactionById(id);
    return map != null ? Transaction.fromMap(map) : null;
  }
}
