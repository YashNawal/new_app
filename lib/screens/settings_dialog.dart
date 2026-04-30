import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String selectedCountry = 'INR - Indian Rupee';
  String selectedLanguage = 'English (EN)';
  String selectedDateFormat = 'dd-MM-yyyy';
  int remindDays = 4;

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);
    const darkBg = Color(0xFF1E1E1E);

    return Dialog(
      backgroundColor: darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: tealColor,
            child: const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader('Currency Setting'),
                const SizedBox(height: 12),
                _buildDropdown('Select Country :', selectedCountry, ['INR - Indian Rupee', 'USD - US Dollar'], (val) => setState(() => selectedCountry = val!)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStaticField('INR')),
                    const SizedBox(width: 8),
                    Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: tealColor, borderRadius: BorderRadius.circular(4)), child: const Text('₹', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown('Language', selectedLanguage, ['English (EN)', 'Hindi (HI)'], (val) => setState(() => selectedLanguage = val!)),
                const SizedBox(height: 12),
                _buildDropdown('Date Format', selectedDateFormat, ['dd-MM-yyyy', 'MM-dd-yyyy'], (val) => setState(() => selectedDateFormat = val!)),
                const SizedBox(height: 20),
                _buildHeader('Transaction Setting'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Remind me before:', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      dropdownColor: darkBg,
                      value: remindDays,
                      items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (val) => setState(() => remindDays = val!),
                    ),
                    const SizedBox(width: 8),
                    const Text('Day(s)', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const Text('It will notify you on or before the reminder days when a transaction is close to being overdue.', style: TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildButton('SAVE', tealColor, () => Navigator.pop(context))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildButton('CLOSE', Colors.transparent, () => Navigator.pop(context), showBorder: true)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.withOpacity(0.1),
      child: Text(title, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Row(
      children: [
        Text('$label : ', style: const TextStyle(color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            dropdownColor: const Color(0xFF1E1E1E),
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildStaticField(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onTap, {bool showBorder = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color, border: showBorder ? Border.all(color: Colors.teal) : null, borderRadius: BorderRadius.circular(8)),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
