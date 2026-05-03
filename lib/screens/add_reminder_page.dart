import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (mounted) {
      setState(() {
        _clients = data;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF59E0B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF59E0B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFF59E0B); // Amber for Reminders
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Schedule Alert'),
        backgroundColor: Colors.white,
      ),
      body: _clients.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No clients found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go back and add a client')),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notification_add_rounded, size: 48, color: accentColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Set Payment Reminder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'Never miss a collection again',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Reminder Details'),
                        const SizedBox(height: 12),
                        _buildClientDropdown(accentColor, lang),
                        const SizedBox(height: 16),
                        _buildAmountField(accentColor, lang),
                        const SizedBox(height: 24),
                        _buildLabel('Schedule'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDateField(accentColor, lang)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTimeField(accentColor)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildNoteField(accentColor, lang),
                        const SizedBox(height: 48),
                        _buildSaveButton(accentColor),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
    );
  }

  Widget _buildClientDropdown(Color color, LanguageProvider lang) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: _selectedClient,
      dropdownColor: Colors.white,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: _inputDecoration(lang.translate('select_client'), Icons.person_outline_rounded, color),
      items: _clients.map((c) {
        return DropdownMenuItem(value: c, child: Text(c['name']));
      }).toList(),
      onChanged: (val) => setState(() => _selectedClient = val),
      validator: (val) => val == null ? 'Please select a client' : null,
    );
  }

  Widget _buildAmountField(Color color, LanguageProvider lang) {
    return TextFormField(
      controller: _amountController,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: _inputDecoration(lang.translate('amount'), Icons.currency_rupee_rounded, color),
      keyboardType: TextInputType.number,
      validator: (val) => val!.isEmpty ? 'Please enter amount' : null,
    );
  }

  Widget _buildDateField(Color color, LanguageProvider lang) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: _inputDecoration(lang.translate('date'), Icons.calendar_today_rounded, color),
        child: Text(
          DateFormat('dd MMM').format(_selectedDate),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTimeField(Color color) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: _inputDecoration('Time', Icons.access_time_rounded, color),
        child: Text(
          _selectedTime.format(context),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNoteField(Color color, LanguageProvider lang) {
    return TextFormField(
      controller: _noteController,
      decoration: _inputDecoration(lang.translate('note'), Icons.note_alt_outlined, color),
      maxLines: 2,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 14),
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  Widget _buildSaveButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
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

            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reminder Set Successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF1E293B),
              ),
            );
            Navigator.pop(context, true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          'Set Reminder Alert',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


