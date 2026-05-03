import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:email_otp/email_otp.dart';
import '../services/language_provider.dart';
import '../services/google_drive_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  
  final EmailOTP _auth = EmailOTP();
  bool _isOTPSent = false;
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Attempting Google Sign In...');
      final account = await GoogleDriveService.signIn();
      
      if (account != null) {
        debugPrint('Google Sign In successful for: ${account.email}');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('useGoogleBackup', true);
        await prefs.setString('userName', account.displayName ?? 'User');
        await prefs.setString('userEmail', account.email);
        await prefs.setString('userMobile', '');

        // Attempt background restore
        GoogleDriveService.restoreDatabase().then((success) {
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome back! Your data has been synced.')),
            );
          }
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userName: account.displayName ?? 'User',
                userEmail: account.email,
                userMobile: '',
              ),
            ),
          );
        }
      } else {
        debugPrint('Google Sign In cancelled or failed (returned null)');
        if (mounted) {
          _showErrorDialog('Google Sign-In Error', 
            'The login process was cancelled or encountered a configuration error. Please ensure you have a stable internet connection or try skipping verification to use the app offline.');
        }
      }
    } catch (e) {
      debugPrint('Google Login Exception: $e');
      if (mounted) {
        _showErrorDialog('Connection Error', 
          'Could not connect to Google. This might be due to missing configuration (SHA-1) or network issues.\n\nError: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveLocalDataAndNavigate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B)),
            child: const Text('Continue Offline'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      _auth.setConfig(
        appEmail: "otp-system@borrowmanager.io",
        appName: "Borrow Manager",
        userEmail: _emailController.text.trim(),
        otpLength: 6,
      );

      bool res = await _auth.sendOTP().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw 'OTP Server is taking too long. Please try again later or skip.';
        },
      );
      
      if (mounted) setState(() => _isLoading = false);

      if (res) {
        setState(() => _isOTPSent = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP Sent! Check your Inbox and Spam folder.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'The OTP server failed. Please try Google Login instead.';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorBypassDialog(e.toString());
      }
    }
  }

  void _showErrorBypassDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Verification Issue'),
          ],
        ),
        content: Text('Message: $errorMessage\n\nWould you like to continue to the app in Offline Mode? You won\'t have cloud backup features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveLocalDataAndNavigate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B)),
            child: const Text('Continue Offline'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOTPAndLogin() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool res = _auth.verifyOTP(otp: _otpController.text);
    setState(() => _isLoading = false);

    if (res) {
      await _saveLocalDataAndNavigate();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please check and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveLocalDataAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('useGoogleBackup', false);
    await prefs.setString('userName', _nameController.text.isEmpty ? 'Guest User' : _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userMobile', _mobileController.text);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: _nameController.text.isEmpty ? 'Guest User' : _nameController.text,
            userEmail: _emailController.text,
            userMobile: _mobileController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: tealColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: tealColor.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, 
                          size: 60, 
                          color: tealColor
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lang.translate('app_title'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: tealColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isOTPSent) ...[
                          Text(
                            lang.translate('create_profile'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login to secure your data with Cloud Backup.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: lang.translate('full_name'),
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: lang.translate('email'),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || !value.contains('@')) ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mobileController,
                            decoration: InputDecoration(
                              labelText: lang.translate('mobile'),
                              prefixIcon: const Icon(Icons.phone_android_rounded),
                              counterText: "",
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _sendOTP,
                            child: const Text('Verify Email & Start'),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR', style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: _handleGoogleLogin,
                            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                            label: const Text('Login with Google (Best for Backup)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _saveLocalDataAndNavigate,
                            child: const Text('Continue Offline (No Cloud Backup)', 
                              style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Verify Your Email',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Enter the 6-digit code sent to ${_emailController.text}'),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'OTP Code',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              counterText: "",
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                            maxLength: 6,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _verifyOTPAndLogin,
                            child: const Text('Verify & Login'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => setState(() => _isOTPSent = false),
                            child: const Text('Change Email'),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text(
                            'Can\'t find the email? Check your Spam/Junk folder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          TextButton(
                            onPressed: _saveLocalDataAndNavigate,
                            child: const Text('Skip and Start Offline', style: TextStyle(color: tealColor)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: tealColor)),
            ),
        ],
      ),
    );
  }
}
