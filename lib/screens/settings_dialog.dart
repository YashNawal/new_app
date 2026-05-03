import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_provider.dart';
import '../services/google_drive_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String selectedCountry = 'INR - Indian Rupee';
  String selectedDateFormat = 'dd-MM-yyyy';
  int remindDays = 4;
  bool _isSyncing = false;

  final List<String> languages = [
    'English (EN)',
    'Hindi (हिन्दी)',
    'Marathi (मराठी)',
    'Gujarati (ગુજરાતી)',
    'Tamil (தமிழ்)',
    'Telugu (తెలుగు)',
    'Kannada (ಕನ್ನಡ)',
    'Bengali (বাংলা)',
    'Spanish (ES)',
    'French (FR)',
    'German (DE)',
  ];

  Future<void> _handleBackup() async {
    setState(() => _isSyncing = true);
    final success = await GoogleDriveService.backupDatabase();
    setState(() => _isSyncing = false);
    
    if (mounted) {
      _showStatusSnackBar(success ? 'Cloud Sync Successful' : 'Backup Failed', success ? const Color(0xFF10B981) : const Color(0xFFF43F5E));
    }
  }

  Future<void> _handleRestore(LanguageProvider lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Restore'),
        content: const Text('This will replace all your current data with the version saved on Google Drive. Are you sure?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF43F5E)),
            child: const Text('Restore Now'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSyncing = true);
      final success = await GoogleDriveService.restoreDatabase();
      setState(() => _isSyncing = false);
      
      if (mounted) {
        _showStatusSnackBar(success ? 'Data Restored! Restarting App...' : 'No Backup Found', success ? const Color(0xFF10B981) : const Color(0xFFF43F5E));
        if (success) Navigator.pop(context);
      }
    }
  }

  void _showStatusSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.settings_suggest_rounded, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'Preferences',
                  style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('CURRENCY'),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCountry,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: ['INR - Indian Rupee', 'USD - US Dollar', 'EUR - Euro']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) => setState(() => selectedCountry = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('LANGUAGE'),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: languageProvider.currentLanguage,
                        icon: const Icon(Icons.language_rounded, size: 18),
                        items: languages.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) => languageProvider.setLanguage(val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('SYNC & DATA'),
                  const SizedBox(height: 16),
                  if (_isSyncing)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else ...[
                    _buildSyncAction(
                      icon: Icons.cloud_upload_rounded,
                      label: 'Backup to Cloud',
                      color: const Color(0xFF6366F1),
                      onTap: _handleBackup,
                    ),
                    const SizedBox(height: 12),
                    _buildSyncAction(
                      icon: Icons.history_rounded,
                      label: 'Restore previous data',
                      color: const Color(0xFF64748B),
                      onTap: () => _handleRestore(languageProvider),
                    ),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text('Close Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildOptionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  Widget _buildSyncAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
