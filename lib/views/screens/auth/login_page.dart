import 'package:flutter/material.dart';
import 'package:borrow_manager/views/screens/home/home_page.dart';

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
  final _passwordController = TextEditingController();

  bool _isSignUp = true;
  bool _backupEnabled = true;
  bool _obscurePassword = true;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: _nameController.text,
            userEmail: _emailController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2BAE66);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ICON
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor,
                  child: const Icon(Icons.shield, color: Colors.white),
                ),

                const SizedBox(height: 15),

                // ✅ ALWAYS SHOW APP NAME
                const Text(
                  "Borrow Manager",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  _isSignUp ? "Join Borrow Manager" : "Welcome Back",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2BAE66)),
                ),

                const SizedBox(height: 10),

                Text(
                  _isSignUp
                      ? "Securely track, manage, and back up your\nprivate loan records."
                      : "Access your account securely",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 25),

                // TOGGLE
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isSignUp
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text("Sign In",
                                  style: TextStyle(
                                      color: !_isSignUp
                                          ? Colors.white
                                          : Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isSignUp = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isSignUp
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      color: _isSignUp
                                          ? Colors.white
                                          : Colors.black)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _isSignUp
                    ? _buildSignUp(primaryColor)
                    : _buildSignIn(primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SIGN IN ----------------
  Widget _buildSignIn(Color primaryColor) {
    return Column(
      children: [
        _input(_emailController, "Email", Icons.email),

        const SizedBox(height: 15),

        _passwordField(),

        const SizedBox(height: 20),

        _mainButton("Sign In", primaryColor),

        const SizedBox(height: 20),

        _divider(),

        const SizedBox(height: 15),

        // ✅ GOOGLE + APPLE WITH BETTER ICONS
        _social("Sign in with Google", "Auto-backup to Drive", Icons.g_mobiledata),
        const SizedBox(height: 10),
        _social("Sign in with Apple", "Secure sync with iCloud", Icons.apple),

        const SizedBox(height: 20),

        _terms(primaryColor),
      ],
    );
  }

  // ---------------- SIGN UP ----------------
  Widget _buildSignUp(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("FULL NAME"),
        _input(_nameController, "John Doe", Icons.person),

        _label("EMAIL ADDRESS"),
        _input(_emailController, "john@example.com", Icons.email),

        _label("MOBILE NUMBER"),
        _mobileField(),

        _label("CREATE PASSWORD"),
        _passwordField(),

        const SizedBox(height: 15),

        GestureDetector(
          onTap: () => setState(() => _backupEnabled = !_backupEnabled),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _backupEnabled
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text("Enable automatic cloud backup"),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        _mainButton("Create account", primaryColor),

        const SizedBox(height: 20),

        _divider(),

        const SizedBox(height: 15),

        _social("Sign in with Google", "Auto-backup to Drive", Icons.g_mobiledata),
        const SizedBox(height: 10),
        _social("Sign in with Apple", "Secure sync with iCloud", Icons.apple),

        const SizedBox(height: 20),

        _terms(primaryColor),
      ],
    );
  }

  // ---------------- WIDGETS ----------------

  Widget _mobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      validator: (value) {
        if (value == null || value.length != 10) {
          return "Enter 10 digit number";
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return "Digits only";
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: "0000000000",
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 5),
    child:
    Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _input(TextEditingController c, String hint, IconData icon) =>
      TextFormField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
        ),
      );

  Widget _mainButton(String text, Color color) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(15),
      ),
      child: Text(text),
    ),
  );

  Widget _divider() => Row(
    children: const [
      Expanded(child: Divider()),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text("OR CONTINUE WITH"),
      ),
      Expanded(child: Divider()),
    ],
  );

  Widget _terms(Color color) => Center(
    child: Text.rich(
      TextSpan(
        text: "By creating an account, you agree to our ",
        children: [
          TextSpan(
              text: "Terms of Service",
              style: TextStyle(color: color)),
          const TextSpan(text: " and "),
          TextSpan(
              text: "Privacy Policy",
              style: TextStyle(color: color)),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );

  Widget _social(String title, String sub, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 12)),
          ],
        )
      ],
    ),
  );
}