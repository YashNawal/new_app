import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/data/models/transaction.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _partialAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().fetchPaymentHistory(widget.transaction.id!);
    });
  }

  void _showPartialPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Partial Payment'),
        content: TextField(
          controller: _partialAmountController,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_partialAmountController.text) ?? 0;
              if (amount > 0) {
                context.read<TransactionViewModel>().makePartialPayment(widget.transaction, amount);
                _partialAmountController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction.clientName)),
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, child) {
          // Find the latest version of this transaction from the VM list
          final currentTx = vm.transactions.firstWhere(
            (t) => t.id == widget.transaction.id,
            orElse: () => widget.transaction,
          );

          return Column(
            children: [
              // --- Summary Header ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: tealColor.withOpacity(0.05),
                child: Column(
                  children: [
                    const Text('Remaining Balance', style: TextStyle(color: Colors.grey)),
                    Text('₹${currentTx.remainingBalance}', 
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: tealColor)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoChip('EMI: ₹${currentTx.emiAmount}'),
                        const SizedBox(width: 8),
                        _infoChip('Rate: ${currentTx.interestRate}%'),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Actions ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: currentTx.status == 'COMPLETED' 
                          ? null 
                          : () => vm.payEMI(currentTx),
                        icon: const Icon(Icons.payment),
                        label: const Text('Pay EMI'),
                        style: ElevatedButton.styleFrom(backgroundColor: tealColor, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: currentTx.status == 'COMPLETED' 
                          ? null 
                          : _showPartialPaymentDialog,
                        icon: const Icon(Icons.add_card),
                        label: const Text('Partial Pay'),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              // --- Payment History List ---
              Expanded(
                child: vm.currentPaymentHistory.isEmpty
                    ? const Center(child: Text('No payments recorded yet.'))
                    : ListView.builder(
                        itemCount: vm.currentPaymentHistory.length,
                        itemBuilder: (context, index) {
                          final p = vm.currentPaymentHistory[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: p.type == 'emi' ? Colors.blue.shade50 : Colors.orange.shade50,
                              child: Icon(
                                p.type == 'emi' ? Icons.calendar_month : Icons.account_balance_wallet,
                                color: p.type == 'emi' ? Colors.blue : Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text(p.type == 'emi' ? 'EMI Payment' : 'Partial Payment'),
                            subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(p.date)),
                            trailing: Text('₹${p.amount}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
