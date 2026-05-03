import 'package:borrow_manager/data/models/payment.dart';
import 'package:borrow_manager/data/sources/local/database_helper.dart';

class PaymentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> addPayment(Payment payment) async {
    await _databaseHelper.insertPayment(payment.toMap());
  }

  Future<List<Payment>> getPaymentsByTransactionId(String transactionId) async {
    final List<Map<String, dynamic>> maps = 
        await _databaseHelper.queryPaymentsByTransaction(transactionId);
    return maps.map((map) => Payment.fromMap(map)).toList();
  }
}
