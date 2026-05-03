import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/views/screens/auth/login_page.dart';
import 'package:borrow_manager/viewmodels/language_provider.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => TransactionViewModel()),
        ChangeNotifierProvider(create: (context) => ClientViewModel()),
      ],
      child: const BorrowManagerApp(),
    ),
  );
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
