import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const BorrowManagerApp());
}

class BorrowManagerApp extends StatelessWidget {
  const BorrowManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Borrow Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          primary: const Color(0xFF00897B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00897B),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

powershell
# 1. Stage all changes
git add .

# 2. Commit the changes
git commit -m "Added client management, login validation, and local database"

# 3. Push to your main branch (using --force to clear the rebase state)
git push origin main --force