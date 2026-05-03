import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'services/language_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userName = prefs.getString('userName') ?? 'User';
  String userEmail = prefs.getString('userEmail') ?? '';
  String userMobile = prefs.getString('userMobile') ?? '';

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: BorrowManagerApp(
        userName: userName,
        userEmail: userEmail,
        userMobile: userMobile,
      ),
    ),
  );
}

class BorrowManagerApp extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userMobile;

  const BorrowManagerApp({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userMobile,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Borrow Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFEC4899),
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1E293B),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: HomePage(
        userName: userName,
        userEmail: userEmail,
        userMobile: userMobile,
      ),
    );
  }
}
