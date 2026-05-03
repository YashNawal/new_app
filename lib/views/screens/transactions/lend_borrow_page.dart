import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/data/models/client.dart';

class LendBorrowPage extends StatefulWidget {
  const LendBorrowPage({super.key});

  @override
  State<LendBorrowPage> createState() => _LendBorrowPageState();
}

class _LendBorrowPageState extends State<LendBorrowPage> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController(text: '0');
  final _rateController = TextEditingController(text: '0');
  final _tenureController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isGave = true; 
  Client? _selectedClient;
  
  double _monthlyEMI = 0.0;
  double _totalInterest = 0.0;
  double _totalPayable = 0.0;

  File? _attachment;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _principalController.addListener(_calculateRepayment);
    _rateController.addListener(_calculateRepayment);
    _tenureController.addListener(_calculateRepayment);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().fetchClients();
    });
  }

  void _calculateRepayment() {
    final p = double.tryParse(_principalController.text) ?? 0;
    final r = double.tryParse(_rateController.text) ?? 0;
    final n = int.tryParse(_tenureController.text) ?? 0;
    
    if (p > 0 && r > 0 && n > 0) {
      final emi = context.read<TransactionViewModel>().calculateEMI(p, r, n);
      setState(() {
        _monthlyEMI = emi;
        _totalPayable = emi * n;
        _totalInterest = _totalPayable - p;
      });
    } else {
      setState(() {
        _monthlyEMI = 0;
        _totalInterest = 0;
        _totalPayable = 0;
      });
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) setState(() => _attachment = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlack = Color(0xFF121212);
    const lightGrey = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        foregroundColor: Colors.white,
        title: const Text('Lend / Borrow'),
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TRANSACTION TYPE', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Expanded(child: _buildTypeToggle('Gave (Lent)', _isGave, Colors.redAccent, () => setState(() => _isGave = true))),
                    Expanded(child: _buildTypeToggle('Received (Borrowed)', !_isGave, Colors.greenAccent.shade700, () => setState(() => _isGave = false))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('SELECT CLIENT', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Consumer<ClientViewModel>(
                builder: (context, vm, child) => Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: DropdownButtonFormField<Client>(
                    value: _selectedClient,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                    hint: const Text('Choose a client'),
                    items: vm.clients.map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: c.imagePath != null ? FileImage(File(c.imagePath!)) : null,
                            child: c.imagePath == null ? const Icon(Icons.person, size: 15) : null,
                          ),
                          const SizedBox(width: 10),
                          Text(c.name),
                        ],
                      ),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedClient = val),
                    validator: (val) => val == null ? 'Please select a client' : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField('LOAN AMOUNT (PRINCIPAL)', _principalController, Icons.currency_rupee),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInputField('INTEREST RATE (%)', _rateController, null)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField('TENURE (MONTHS)', _tenureController, null)),
                ],
              ),
              const SizedBox(height: 24),
              _buildEMIDisplay(),
              const SizedBox(height: 24),
              _buildRepaymentPreview(),
              const SizedBox(height: 24),
              const Text('ATTACHMENTS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildAttachmentBtn('Camera', Icons.camera_alt_outlined, () => _pickAttachment(ImageSource.camera))),
                  const SizedBox(width: 15),
                  Expanded(child: _buildAttachmentBtn('Upload File', Icons.attach_file, () => _pickAttachment(ImageSource.gallery))),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('Create Loan Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(String label, bool isSelected, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, size: 18) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEMIDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly EMI', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('₹ ${_monthlyEMI.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                child: Text('${_rateController.text}% Interest', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmiMetric('TOTAL INTEREST', '₹ ${_totalInterest.toStringAsFixed(2)}'),
              _buildEmiMetric('TOTAL PAYABLE', '₹ ${_totalPayable.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmiMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildRepaymentPreview() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('REPAYMENT PREVIEW', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View Full', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))),
          ],
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: List.generate(3, (index) => ListTile(
              title: Text('Month ${index + 1}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              trailing: Text('₹ ${_monthlyEMI.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate.add(Duration(days: 30 * (index + 1)))), style: const TextStyle(fontSize: 11)),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: Colors.grey), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await context.read<TransactionViewModel>().createLoan(
        clientName: _selectedClient!.name,
        principal: double.parse(_principalController.text),
        annualRate: double.parse(_rateController.text),
        tenureMonths: int.parse(_tenureController.text),
        isLent: _isGave,
        date: _selectedDate,
        note: _noteController.text,
      );
      if (mounted) Navigator.pop(context);
    }
  }
}
