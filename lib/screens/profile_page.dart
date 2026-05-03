import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_provider.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userMobile;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userMobile,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profilePic;
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _descController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController(text: widget.userEmail);
    _mobileController = TextEditingController(text: widget.userMobile);
    _descController = TextEditingController();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _businessNameController.text = prefs.getString('businessName') ?? 'Borrow Manager User';
      _addressController.text = prefs.getString('businessAddress') ?? 'India';
      _descController.text = prefs.getString('businessDesc') ?? 'Managing my borrows and lends.';
    });
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userMobile', _mobileController.text);
    await prefs.setString('businessName', _businessNameController.text);
    await prefs.setString('businessAddress', _addressController.text);
    await prefs.setString('businessDesc', _descController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePic = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
                          child: _profilePic == null 
                            ? Icon(Icons.person_rounded, size: 60, color: primaryColor.withValues(alpha: 0.5)) 
                            : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text.isEmpty ? 'User' : _nameController.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('PERSONAL INFO'),
                  const SizedBox(height: 12),
                  _buildModernField('Full Name', _nameController, Icons.person_outline_rounded, primaryColor),
                  const SizedBox(height: 16),
                  _buildModernField('Email Address', _emailController, Icons.email_outlined, primaryColor),
                  const SizedBox(height: 16),
                  _buildModernField('Mobile Number', _mobileController, Icons.phone_android_rounded, primaryColor),
                  
                  const SizedBox(height: 32),
                  _buildSectionLabel('BUSINESS DETAILS'),
                  const SizedBox(height: 12),
                  _buildModernField('Business Name', _businessNameController, Icons.business_center_outlined, primaryColor),
                  const SizedBox(height: 16),
                  _buildModernField('Location', _addressController, Icons.location_on_outlined, primaryColor),
                  const SizedBox(height: 16),
                  _buildModernField('Description', _descController, Icons.description_outlined, primaryColor, maxLines: 3),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w800, 
        color: Color(0xFF94A3B8), 
        letterSpacing: 1.2
      ),
    );
  }

  Widget _buildModernField(String label, TextEditingController controller, IconData icon, Color accentColor, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.normal, fontSize: 14),
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}
