import 'package:flutter/material.dart';
import 'package:borrow_manager/data/models/client.dart';
import 'package:borrow_manager/data/sources/local/database_helper.dart';

class ClientViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;

  Future<void> fetchClients() async {
    _isLoading = true;
    notifyListeners();
    final data = await _dbHelper.queryAllClients();
    _clients = data.map((e) => Client.fromMap(e)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    await _dbHelper.insertClient(client.toMap());
    await fetchClients();
  }
}
