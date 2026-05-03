import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/language_provider.dart';

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
  bool _isGave = true; 
  String? _selectedClient;
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isGave ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final themeColor = _isGave ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.white,
      ),
      body: _clients.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
                const SizedBox(height: 16),
                const Text('No clients found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go back and add a client')),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildTypeSwitcher(themeColor),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Transaction Details'),
                        const SizedBox(height: 12),
                        _buildClientDropdown(themeColor),
                        const SizedBox(height: 16),
                        _buildAmountField(themeColor),
                        const SizedBox(height: 24),
                        _buildLabel('Additional Info'),
                        const SizedBox(height: 12),
                        _buildDateField(themeColor),
                        const SizedBox(height: 16),
                        _buildNoteField(themeColor),
                        const SizedBox(height: 48),
                        _buildSaveButton(themeColor, lang),
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

  Widget _buildTypeSwitcher(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTypeButton('I GAVE (Lent)', true, const Color(0xFFF43F5E))),
                Expanded(child: _buildTypeButton('I GOT (Borrowed)', false, const Color(0xFF10B981))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isGave ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
              key: ValueKey(_isGave),
              size: 64,
              color: themeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool value, Color activeColor) {
    bool isSelected = _isGave == value;
    return GestureDetector(
      onTap: () => setState(() => _isGave = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
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

  Widget _buildClientDropdown(Color themeColor) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedClient,
      dropdownColor: Colors.white,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: _inputDecoration('Select Client', Icons.person_outline_rounded, themeColor),
      items: _clients.map((c) {
        return DropdownMenuItem(value: c['name'].toString(), child: Text(c['name']));
      }).toList(),
      onChanged: (val) => setState(() => _selectedClient = val),
      validator: (val) => val == null ? 'Please select a client' : null,
    );
  }

  Widget _buildAmountField(Color themeColor) {
    return TextFormField(
      controller: _amountController,
      style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
      decoration: _inputDecoration('Amount', Icons.currency_rupee_rounded, themeColor).copyWith(
        prefixIcon: Icon(Icons.currency_rupee_rounded, color: themeColor, size: 28),
      ),
      keyboardType: TextInputType.number,
      validator: (val) => val!.isEmpty ? 'Please enter amount' : null,
    );
  }

  Widget _buildDateField(Color themeColor) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: _inputDecoration('Date', Icons.calendar_today_rounded, themeColor),
        child: Text(
          DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNoteField(Color themeColor) {
    return TextFormField(
      controller: _noteController,
      decoration: _inputDecoration('Remark / Note', Icons.note_alt_outlined, themeColor),
      maxLines: 2,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.normal, fontSize: 14),
      prefixIcon: Icon(icon, color: color.withValues(alpha: 0.7)),
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

  Widget _buildSaveButton(Color themeColor, LanguageProvider lang) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            await DatabaseHelper().insertTransaction({
              'clientName': _selectedClient,
              'amount': double.parse(_amountController.text),
              'isLent': _isGave ? 1 : 0,
              'date': _selectedDate.toIso8601String(),
              'note': _noteController.text,
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Record Saved Successfully'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context, true);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          'Confirm Transaction',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
