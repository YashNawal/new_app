class Payment {
  final String? id;
  final String transactionId;
  final double amount;
  final DateTime date;
  final String type; // 'emi' or 'partial'

  Payment({
    this.id,
    required this.transactionId,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString(),
      transactionId: map['transaction_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
