import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/views/screens/clients/add_client_page.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Owes Me', 'I Owe', 'Settled'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<ClientViewModel>(
        builder: (context, vm, child) {
          final filteredClients = vm.clients.where((c) {
            bool matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase());
            if (!matchesSearch) return false;
            
            if (_selectedFilter == 'Owes Me') return c.isOwesMe && c.balance > 0;
            if (_selectedFilter == 'I Owe') return !c.isOwesMe && c.balance > 0;
            if (_selectedFilter == 'Settled') return c.balance == 0;
            return true;
          }).toList();

          return Column(
            children: [
              _buildHeader(primaryGreen),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildSectionHeader(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: vm.isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : filteredClients.isEmpty
                            ? const Center(child: Text('No clients found'))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredClients.length,
                                itemBuilder: (context, index) {
                                  final client = filteredClients[index];
                                  return _buildClientCard(client);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClientPage())),
        backgroundColor: const Color(0xFF2D6A4F),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildHeader(Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white),
                const Text('Manage Clients', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const CircleAvatar(radius: 18, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search clients',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: _filters.map((filter) => _buildFilterChip(filter)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF409167) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('RECENT CLIENTS', style: TextStyle(letterSpacing: 1.2, color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
        Icon(Icons.tune, color: Colors.grey[400], size: 20),
      ],
    );
  }

  Widget _buildClientCard(dynamic client) {
    bool isSettled = client.balance == 0;
    bool isOwe = !client.isOwesMe;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: client.imagePath != null ? FileImage(File(client.imagePath!)) : null,
            child: client.imagePath == null ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Last activity: Just now', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSettled ? '' : (isOwe ? '' : '+')}₹${client.balance}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSettled ? Colors.grey : (isOwe ? Colors.red[800] : Colors.green[800]),
                ),
              ),
              Text(
                isSettled ? 'SETTLED' : (isOwe ? 'YOU OWE' : 'YOU RECEIVE'),
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
