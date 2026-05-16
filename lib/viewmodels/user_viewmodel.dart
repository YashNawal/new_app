import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {

  String _name = "Guest User";
  String _email = "guest@email.com";

  String get name => _name;
  String get email => _email;

  void setUser({
    required String name,
    required String email,
  }) {
    _name = name;
    _email = email;

    notifyListeners();
  }

  void clearUser() {
    _name = "";
    _email = "";

    notifyListeners();
  }
}