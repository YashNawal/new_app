import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/views/screens/clients/add_client_page.dart';
import 'package:borrow_manager/views/screens/clients/client_detail_page.dart';

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
      backgroundColor: Colors.white,
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
                                  return InkWell(
                                    onTap: () => Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => ClientDetailPage(client: client))
                                    ),
                                    child: _buildClientCard(client),
                                  );
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

      padding: const EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
        bottom: 10,
      ),

      color: const Color(0xFF009688),

      child: Row(

        children: [

          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),

            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(

              "Clients List",

              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Icon(
            Icons.search,
            color: Colors.white,
            size: 30,
          ),

          const SizedBox(width: 20),

          const Icon(
            Icons.person_add_alt_outlined,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }




  Widget _buildClientCard(dynamic client) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          /// PROFILE IMAGE

          CircleAvatar(
            radius: 32,

            backgroundColor: Colors.white,

            backgroundImage:
            client.imagePath != null
                ? FileImage(File(client.imagePath!))
                : null,

            child: client.imagePath == null
                ? Icon(
              Icons.person_outline,
              size: 50,
              color: Colors.grey.shade700,
            )
                : null,
          ),

          const SizedBox(width: 14),

          /// CLIENT DETAILS

          Expanded(

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// NAME

                Text(
                  client.name,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                /// GAVE + RECEIVED

                Row(
                  children: [

                    /// GAVE

                    Row(
                      children: [

                        Container(

                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade50,
                          ),

                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "₹:${client.isOwesMe ? client.balance : 0.0}",

                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 40),

                    /// RECEIVED

                    Row(
                      children: [

                        Container(

                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.shade50,
                          ),

                          child: const Icon(
                            Icons.arrow_downward,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "₹:${!client.isOwesMe ? client.balance : 0.0}",

                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// MORE ICON

          Padding(
            padding: const EdgeInsets.only(top: 10),

            child: Icon(
              Icons.more_vert,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
