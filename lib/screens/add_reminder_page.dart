import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';
import '../services/language_provider.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({super.key});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  Map<String, dynamic>? _selectedClient;
  List<Map<String, dynamic>> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final data = await DatabaseHelper().queryAllClients();
    setState(() {
      _clients = data;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add Reminder')),
      body: _clients.isEmpty 
        ? Center(child: Text(lang.translate('no_contacts')))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedClient,
                    decoration: InputDecoration(
                      labelText: lang.translate('select_client'),
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    items: _clients.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c['name']));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedClient = val),
                    validator: (val) => val == null ? 'Please select a client' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: lang.translate('amount'),
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Please enter amount' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: lang.translate('date'),
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            child: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: lang.translate('note'),
                      prefixIcon: const Icon(Icons.note_alt_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final reminderDateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );

                          await DatabaseHelper().insertReminder({
                            'clientId': _selectedClient!['id'],
                            'clientName': _selectedClient!['name'],
                            'amount': double.parse(_amountController.text),
                            'reminderDateTime': reminderDateTime.toIso8601String(),
                            'note': _noteController.text,
                            'isCompleted': 0,
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder Set Successfully'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      child: const Text('Set Reminder'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
