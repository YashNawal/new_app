import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:borrow_manager/data/models/client.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idProofController = TextEditingController();
  final _remarkController = TextEditingController();

  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0B9B8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Client',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Container(

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                /// TOP SECTION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    /// IMAGE + BUTTON
                    Column(
                      children: [

                        GestureDetector(
                          onTap: _showImagePickerOptions,

                          child: Container(
                            padding: const EdgeInsets.all(0), // ring thickness

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: Colors.grey, // ring color
                                width: 3,
                              ),
                            ),

                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,

                              backgroundImage:
                              _image != null
                                  ? FileImage(_image!)
                                  : null,

                              child: _image == null
                                  ? Icon(
                                Icons.person_outline,
                                size: 60,
                                color: Colors.grey.shade600,
                              )
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: 125,
                          height: 45,

                          child: OutlinedButton(
                            onPressed: _showImagePickerOptions,

                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF1B5E7A),
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),

                            child: const Text(
                              "Add Photo",
                              style: TextStyle(
                                color: Color(0xFF6B6B6B),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 22),

                    /// RIGHT SIDE FIELDS
                    Expanded(
                      child: Column(
                        children: [

                          /// CLIENT NAME
                          _buildLineField(
                            controller: _nameController,
                            hint: "Client Name *",
                            suffixIcon: Icons.search,

                            validator: (val) =>
                            val!.isEmpty
                                ? 'Please enter name'
                                : null,
                          ),

                          const SizedBox(height: 28),

                          /// ADDRESS
                          _buildLineField(
                            controller: _addressController,
                            hint: "Address",
                            ),
                          const SizedBox(height: 35),

                          /// MOBILE
                          _buildLineField(
                            controller: _phoneController,
                            hint: "Mobile *",

                            validator: (val) =>
                            val!.isEmpty
                                ? 'Please enter phone'
                                : null,
                          ),
                          const SizedBox(height: 42),

                          /// ID PROOF
                          _buildLineField(
                            controller: _idProofController,
                            hint: "Id Proof",
                          ),

                          const SizedBox(height: 42),

                          /// REMARK
                          _buildLineField(
                            controller: _remarkController,
                            hint: "Remark",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),





                const SizedBox(height: 55),

                /// BUTTONS
                Row(
                  children: [

                    /// SAVE BUTTON
                    Expanded(
                      child: SizedBox(
                        height: 72,

                        child: OutlinedButton(
                          onPressed: () async {

                            if (_formKey.currentState!.validate()) {

                              String? imagePath;

                              if (_image != null) {

                                final directory =
                                await getApplicationDocumentsDirectory();

                                final fileName =
                                p.basename(_image!.path);

                                final savedImage =
                                await _image!.copy(
                                  '${directory.path}/$fileName',
                                );

                                imagePath = savedImage.path;
                              }

                              final client = Client(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                email: _emailController.text,
                                address: _addressController.text,
                                imagePath: imagePath,
                              );

                              await context
                                  .read<ClientViewModel>()
                                  .addClient(client);

                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          },

                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.blue.shade100,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),

                          child: const Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 25),

                    /// CLOSE BUTTON
                    Expanded(
                      child: SizedBox(
                        height: 72,

                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.red.shade300,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),

                          child: const Text(
                            "Close",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {

    return TextFormField(
      controller: controller,
      validator: validator,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 18,
        ),

        suffixIcon: suffixIcon != null
            ? Icon(
          suffixIcon,
          color: Colors.black,
          size: 32,
        )
            : null,

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.teal,
            width: 1.5,
          ),
        ),
      ),

      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }
}
