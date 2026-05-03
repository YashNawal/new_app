import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_provider.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const securityColor = Color(0xFF3B82F6); // Trust Blue
    const darkSlate = Color(0xFF1E293B);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Security & Privacy'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: securityColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, size: 64, color: securityColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Data Privacy Policy',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: darkSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your data security is our top priority',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: const Text(
                      'Borrow Manager operates on a zero-server architecture. All your transactions are stored locally on your device or in your personal Google Drive. We never see or store your financial data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('REQUIRED PERMISSIONS'),
                  const SizedBox(height: 16),
                  _buildPermissionItem(Icons.contacts_rounded, 'Contacts Access', 'Used only to link names to your transactions.'),
                  _buildPermissionItem(Icons.storage_rounded, 'Storage Access', 'Required to save exported PDF reports locally.'),
                  _buildPermissionItem(Icons.cloud_sync_rounded, 'Google Drive', 'Enables secure automated backup and restoration.'),
                  _buildPermissionItem(Icons.notifications_active_rounded, 'Notifications', 'Required to alert you about upcoming due dates.'),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkSlate,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('UNDERSTOOD', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w800, 
        color: Color(0xFF94A3B8), 
        letterSpacing: 1.2
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
