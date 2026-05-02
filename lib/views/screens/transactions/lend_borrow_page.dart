import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';

class LendBorrowPage extends StatefulWidget {
  const LendBorrowPage({super.key});

  @override
  State<LendBorrowPage> createState() => _LendBorrowPageState();
}

class _LendBorrowPageState extends State<LendBorrowPage> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isGave = true; 
  String? _selectedClient;
  double _calculatedEMI = 0.0;

  final List<String> _clients = ['Sachin Mugade', 'Yash Nawal', 'Rahul Sharma', 'Amit Kumar'];

  @override
  void initState() {
    super.initState();
    _principalController.addListener(_updateEMI);
    _rateController.addListener(_updateEMI);
    _tenureController.addListener(_updateEMI);
  }

  void _updateEMI() {
    final p = double.tryParse(_principalController.text) ?? 0;
    final r = double.tryParse(_rateController.text) ?? 0;
    final n = int.tryParse(_tenureController.text) ?? 0;
    
    if (p > 0 && r > 0 && n > 0) {
      setState(() {
        _calculatedEMI = context.read<TransactionViewModel>().calculateEMI(p, r, n);
      });
    } else {
      setState(() => _calculatedEMI = 0.0);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(title: const Text('New Loan Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isGave = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isGave ? Colors.red : Colors.grey.shade200,
                        foregroundColor: _isGave ? Colors.white : Colors.black,
                      ),
                      child: const Text('Gave (Lent)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isGave = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isGave ? Colors.green : Colors.grey.shade200,
                        foregroundColor: !_isGave ? Colors.white : Colors.black,
                      ),
                      child: const Text('Received (Borrowed)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedClient,
                decoration: const InputDecoration(labelText: 'Select Client', border: OutlineInputBorder()),
                items: _clients.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedClient = val),
                validator: (val) => val == null ? 'Please select a client' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _principalController,
                decoration: const InputDecoration(labelText: 'Loan Amount (Principal)', prefixIcon: Icon(Icons.currency_rupee), border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(labelText: 'Interest Rate (%)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tenureController,
                      decoration: const InputDecoration(labelText: 'Tenure (Months)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: tealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly EMI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('₹$_calculatedEMI', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: tealColor)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await context.read<TransactionViewModel>().createLoan(
                        clientName: _selectedClient!,
                        principal: double.parse(_principalController.text),
                        annualRate: double.parse(_rateController.text),
                        tenureMonths: int.parse(_tenureController.text),
                        isLent: _isGave,
                        date: _selectedDate,
                        note: _noteController.text,
                      );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: tealColor, foregroundColor: Colors.white),
                  child: const Text('Create Loan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
