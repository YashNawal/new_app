import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);
    const darkBg = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Data Privacy Declaration'),
        backgroundColor: tealColor,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkBg,
            border: Border.all(color: Colors.grey.shade800),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Declaration !', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'The following permissions are required according to the basic functionality of the software. We never store your data in our server side. All data is saved locally to your device and Google Drive account that you have linked.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text('Read the privacy policy', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
              const SizedBox(height: 20),
              _buildPermissionItem(Icons.contacts_outlined, 'Read Contacts', 'Necessary to do share transactions with your friends/colleagues'),
              _buildPermissionItem(Icons.folder_open_outlined, 'Read/Write Files', 'Required to read and save files on the local device. We only access path /sdcard/BorrowManager/'),
              _buildPermissionItem(Icons.phone_outlined, 'Phone call', 'Permission is required to dial the call from the application when the user needs it.'),
              _buildPermissionItem(Icons.ads_click, 'Display Ads', 'We will display advertisements in software to generate revenue which helps us to serve better. You can subscribe to our service to remove ads.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
