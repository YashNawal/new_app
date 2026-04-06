import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LendBorrowPage extends StatefulWidget {
  const LendBorrowPage({super.key});

  @override
  State<LendBorrowPage> createState() => _LendBorrowPageState();
}

class _LendBorrowPageState extends State<LendBorrowPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isGave = true; // True for "Gave" (Lent), False for "Received" (Borrowed)
  String? _selectedClient;

  // Mock data for clients - in a real app, this would come from a database
  final List<String> _clients = ['Sachin Mugade', 'Yash Nawal', 'Rahul Sharma', 'Amit Kumar'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lend/Borrow'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Transaction Type Toggle ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isGave = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isGave ? Colors.red : Colors.grey.shade200,
                        foregroundColor: _isGave ? Colors.white : Colors.black,
                        elevation: 0,
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
                        elevation: 0,
                      ),
                      child: const Text('Received (Borrowed)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Client Selection ---
              DropdownButtonFormField<String>(
                value: _selectedClient,
                decoration: InputDecoration(
                  labelText: 'Select Client',
                  prefixIcon: const Icon(Icons.person_outline, color: tealColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _clients.map((String client) {
                  return DropdownMenuItem(value: client, child: Text(client));
                }).toList(),
                onChanged: (val) => setState(() => _selectedClient = val),
                validator: (val) => val == null ? 'Please select a client' : null,
              ),
              const SizedBox(height: 16),

              // --- Amount Field ---
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.currency_rupee, color: tealColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Please enter amount' : null,
              ),
              const SizedBox(height: 16),

              // --- Date Picker ---
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today, color: tealColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // --- Note Field ---
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: const Icon(Icons.note_alt_outlined, color: tealColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 40),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save transaction logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaction saved: ${_isGave ? 'Gave' : 'Received'} ₹${_amountController.text}'),
                          backgroundColor: _isGave ? Colors.red : Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
