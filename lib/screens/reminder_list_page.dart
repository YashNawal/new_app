import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/language_provider.dart';
import 'add_reminder_page.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshReminders();
  }

  Future<void> _refreshReminders() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAllReminders();
    if (mounted) {
      setState(() {
        _reminders = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFF59E0B); // Amber for Reminders
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(lang.translate('reminders')),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _buildEmptyState(lang)
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final rem = _reminders[index];
                    final DateTime dateTime = DateTime.parse(rem['reminderDateTime']);
                    return _buildReminderCard(rem, dateTime, accentColor, lang);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderPage()),
          );
          if (result == true) _refreshReminders();
        },
        label: const Text('Add Alert', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_alarm_rounded),
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> rem, DateTime dateTime, Color accentColor, LanguageProvider lang) {
    final bool isOverdue = dateTime.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isOverdue ? Colors.orange.withValues(alpha: 0.2) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isOverdue ? Colors.orange : accentColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isOverdue ? Icons.priority_high_rounded : Icons.notifications_active_rounded,
                    color: isOverdue ? Colors.orange : accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rem['clientName'],
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMM • hh:mm a').format(dateTime),
                        style: TextStyle(
                          color: isOverdue ? const Color(0xFFC2410C) : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${rem['amount']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          if (rem['note'] != null && rem['note'].isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rem['note'],
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await DatabaseHelper().updateReminderStatus(rem['id'], 1);
                    _refreshReminders();
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('Mark Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                ),
                const SizedBox(height: 24, child: VerticalDivider(width: 1)),
                TextButton.icon(
                  onPressed: () async {
                    await DatabaseHelper().deleteReminder(rem['id']);
                    _refreshReminders();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(Icons.alarm_off_rounded, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          Text(
            'No pending alerts',
            style: GoogleFonts.plusJakartaSans(fontSize: 20, color: const Color(0xFF475569), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set reminders to track your payments',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
