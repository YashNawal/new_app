import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:borrow_manager/data/models/transaction.dart';
import 'package:borrow_manager/data/models/payment.dart';
import 'package:borrow_manager/data/repositories/transaction_repository.dart';
import 'package:borrow_manager/data/repositories/payment_repository.dart';
import 'package:borrow_manager/core/utils/emi_calculator.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final _uuid = const Uuid();

  List<Transaction> _transactions = [];
  List<Payment> _currentPaymentHistory = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  List<Payment> get currentPaymentHistory => _currentPaymentHistory;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _transactionRepo.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  /// Calculates EMI for a potential loan without saving.
  double calculateEMI(double principal, double annualRate, int tenure) {
    return EMICalculator.calculateEMI(principal, annualRate, tenure);
  }

  /// Creates a new Loan Transaction
  Future<void> createLoan({
    required String clientName,
    required double principal,
    required double annualRate,
    required int tenureMonths,
    required bool isLent,
    required DateTime date,
    String note = '',
  }) async {
    final emi = calculateEMI(principal, annualRate, tenureMonths);
    
    final transaction = Transaction(
      id: _uuid.v4(),
      clientName: clientName,
      principal: principal,
      interestRate: annualRate,
      tenureMonths: tenureMonths,
      emiAmount: emi,
      remainingBalance: principal,
      isLent: isLent,
      date: date,
      note: note,
    );

    await _transactionRepo.addTransaction(transaction);
    await fetchTransactions();
  }

  /// Handles EMI Payment Logic
  Future<void> payEMI(Transaction transaction) async {
    await makePayment(
      transaction: transaction,
      amount: transaction.emiAmount,
      type: 'emi',
    );
  }

  /// Handles Partial Payment Logic
  Future<void> makePartialPayment(Transaction transaction, double amount) async {
    await makePayment(
      transaction: transaction,
      amount: amount,
      type: 'partial',
    );
  }

  /// Generic Payment Handler
  Future<void> makePayment({
    required Transaction transaction,
    required double amount,
    required String type,
  }) async {
    if (transaction.id == null) return;

    // 1. Calculate Interest based on remaining balance
    double monthlyInterest = EMICalculator.calculateMonthlyInterest(
      transaction.remainingBalance, 
      transaction.interestRate
    );

    // 2. Principal Reduction = Payment - Interest
    // Note: If payment < interest, balance might increase or we can handle differently.
    // Standard rule: Interest is paid first.
    double principalReduction = amount - monthlyInterest;
    double newBalance = transaction.remainingBalance - principalReduction;

    // Prevent negative balance
    if (newBalance < 0) newBalance = 0;

    // 3. Update Transaction
    final updatedTransaction = Transaction(
      id: transaction.id,
      clientName: transaction.clientName,
      principal: transaction.principal,
      interestRate: transaction.interestRate,
      tenureMonths: transaction.tenureMonths,
      emiAmount: transaction.emiAmount,
      remainingBalance: double.parse(newBalance.toStringAsFixed(2)),
      isLent: transaction.isLent,
      date: transaction.date,
      note: transaction.note,
      status: newBalance <= 0 ? 'COMPLETED' : 'ACTIVE',
    );

    // 4. Record Payment
    final payment = Payment(
      id: _uuid.v4(),
      transactionId: transaction.id!,
      amount: amount,
      date: DateTime.now(),
      type: type,
    );

    await _transactionRepo.updateTransaction(updatedTransaction);
    await _paymentRepo.addPayment(payment);
    
    await fetchTransactions();
    await fetchPaymentHistory(transaction.id!);
  }

  Future<void> fetchPaymentHistory(String transactionId) async {
    _currentPaymentHistory = await _paymentRepo.getPaymentsByTransactionId(transactionId);
    notifyListeners();
  }

  double get totalLentBalance => _transactions
      .where((t) => t.isLent && t.status == 'ACTIVE')
      .fold(0.0, (sum, t) => sum + t.remainingBalance);

  double get totalBorrowedBalance => _transactions
      .where((t) => !t.isLent && t.status == 'ACTIVE')
      .fold(0.0, (sum, t) => sum + t.remainingBalance);
}
