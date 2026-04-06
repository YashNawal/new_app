import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'add_client_page.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  List<Map<String, dynamic>> _clients = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshClients();
  }

  Future<void> _refreshClients() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAllClients();
    setState(() {
      _clients = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);

    final filteredClients = _clients
        .where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search Client...',
                prefixIcon: const Icon(Icons.search, color: tealColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClients.isEmpty
                    ? const Center(child: Text('No clients found.'))
                    : ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          final balance = client['balance'] ?? 0.0;
                          final bool isOwesMe = client['isOwesMe'] == 1;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tealColor.withOpacity(0.1),
                                child: const Icon(Icons.person, color: tealColor),
                              ),
                              title: Text(client['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(client['phone']),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹$balance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: balance == 0
                                          ? Colors.grey
                                          : (isOwesMe ? Colors.green : Colors.red),
                                    ),
                                  ),
                                  Text(
                                    balance == 0 ? 'Settled' : (isOwesMe ? 'Owes Me' : 'I Owe'),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientPage()),
          );

          if (result == true) {
            _refreshClients(); // Refresh list if a client was added
          }
        },
        backgroundColor: tealColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
