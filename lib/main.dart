import 'package:borrow_manager/views/screens/home/home_page.dart';
import 'package:borrow_manager/views/screens/settings/backup_screen.dart';
import 'package:borrow_manager/views/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/views/screens/auth/login_page.dart';
import 'package:borrow_manager/viewmodels/language_provider.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/viewmodels/user_viewmodel.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => TransactionViewModel()),
        ChangeNotifierProvider(create: (context) => ClientViewModel()),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(),
        ),
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
      ),

      initialRoute: AppRoutes.login,

      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(userName: '', userEmail: '',),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.backup: (context) => const BackupScreen(),
      },
    );
  }
}

class SettingsPage {
  const SettingsPage();
}