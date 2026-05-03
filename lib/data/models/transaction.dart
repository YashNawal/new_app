class Transaction {
  final String? id;
  final String clientName;
  final double principal;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final double remainingBalance;
  final bool isLent; // true if I lent (I receive EMI), false if I borrowed (I pay EMI)
  final DateTime date;
  final String note;
  final String status; // 'ACTIVE', 'COMPLETED'

  Transaction({
    this.id,
    required this.clientName,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.remainingBalance,
    required this.isLent,
    required this.date,
    this.note = '',
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'principal': principal,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'emi_amount': emiAmount,
      'remaining_balance': remainingBalance,
      'isLent': isLent ? 1 : 0,
      'date': date.toIso8601String(),
      'note': note,
      'status': status,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString(),
      clientName: map['clientName'],
      principal: map['principal'],
      interestRate: map['interest_rate'],
      tenureMonths: map['tenure_months'],
      emiAmount: map['emi_amount'],
      remainingBalance: map['remaining_balance'],
      isLent: map['isLent'] == 1,
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      status: map['status'] ?? 'ACTIVE',
    );
  }
}
