import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/language_provider.dart';
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
    if (mounted) {
      setState(() {
        _clients = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF3B82F6); // Modern Blue for Clients
    final lang = Provider.of<LanguageProvider>(context);

    final filteredClients = _clients
        .where((c) => c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(lang.translate('clients')),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: lang.translate('search_client'),
                prefixIcon: const Icon(Icons.search_rounded, color: accentColor),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredClients.isEmpty
                    ? _buildEmptyState(lang)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filteredClients.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          final balance = client['balance'] ?? 0.0;
                          final bool isOwesMe = client['isOwesMe'] == 1;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              child: ListTile(
                                onTap: () {}, 
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [accentColor.withValues(alpha: 0.2), accentColor.withValues(alpha: 0.05)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      client['name'][0].toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  client['name'],
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 4),
                                    Text(
                                      client['phone'],
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹$balance',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: balance == 0
                                            ? const Color(0xFF94A3B8)
                                            : (isOwesMe ? const Color(0xFF10B981) : const Color(0xFFF43F5E)),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: balance == 0
                                            ? const Color(0xFFF8FAFC)
                                            : (isOwesMe ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        balance == 0 
                                            ? 'Settled' 
                                            : (isOwesMe ? 'You get' : 'You give'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: balance == 0
                                              ? const Color(0xFF64748B)
                                              : (isOwesMe ? const Color(0xFF059669) : const Color(0xFFE11D48)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientPage()),
          );
          if (result == true) _refreshClients();
        },
        label: const Text('Add Client', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: const Icon(Icons.people_outline_rounded, size: 64, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'No clients yet' : 'No matching results',
            style: GoogleFonts.plusJakartaSans(fontSize: 20, color: const Color(0xFF475569), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first client to start tracking',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
