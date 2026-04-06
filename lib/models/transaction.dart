class Transaction {
  final String clientName;
  final double amount;
  final bool isLent; // true if I gave (Lent), false if I received (Borrowed)
  final DateTime date;
  final String note;

  Transaction({
    required this.clientName,
    required this.amount,
    required this.isLent,
    required this.date,
    this.note = '',
  });
}
