import 'package:flutter/material.dart';
import 'add_client_page.dart';
import 'clients_list_page.dart';
import 'lend_borrow_page.dart';
import 'reminder_list_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _allClients = [];

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context, tealColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Dashboard Card ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 30, color: Colors.grey),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Balance', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text('₹0.0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceItem(Icons.arrow_upward, 'Gave', '₹0.0', Colors.red),
                          Container(height: 40, width: 1, color: Colors.grey.shade300),
                          _buildBalanceItem(Icons.arrow_downward, 'Received', '₹0.0', Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Quick Actions Grid ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(context, Icons.person_add_outlined, 'Add Client', const AddClientPage()),
                  _buildActionButton(context, Icons.assignment_ind_outlined, 'Clients List', const ClientsListPage()),
                  _buildActionButton(context, Icons.swap_horiz, 'Lend/Borrow', const LendBorrowPage()),
                  _buildActionButton(context, Icons.notifications_none, 'Reminder List', const ReminderListPage()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Info List Cards ---
            _buildInfoCard(Icons.handshake_outlined, 'Add your first Lend/Borrow record', null, tealColor),
            _buildInfoCard(Icons.cloud_queue, 'Backup/Restore data with Google Drive', 'Enable cloud backup setting to Backup/Restore your data', tealColor),
            _buildInfoCard(Icons.shopping_cart_outlined, 'Purchase Subscribe', 'you can purchase subscription to remove ads and access all features.', tealColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(IconData icon, String label, String amount, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Widget targetPage) {
    return InkWell(
      onTap: () async {
        if (targetPage is AddClientPage) {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
          if (result != null) {
             // To persist across screens properly, we'll eventually need a state management solution 
             // or database. For now, we'll just navigate to list to see it.
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsListPage()));
          }
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.22,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00897B), size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String? subtitle, Color tealColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: ListTile(
          leading: Icon(icon, color: tealColor, size: 30),
          title: Text(title, style: TextStyle(color: tealColor, fontWeight: FontWeight.w500)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Color tealColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: tealColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),
            accountName: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.userEmail),
          ),
          _drawerItem(Icons.cloud_upload_outlined, 'Backup/Restore'),
          _drawerItem(Icons.share_outlined, 'Share With Friends'),
          _drawerItem(Icons.star_outline, 'Rate Us'),
          _drawerItem(Icons.bar_chart, 'Report/Support'),
          _drawerItem(Icons.settings_outlined, 'Settings'),
          _drawerItem(Icons.person_outline, 'User Profile'),
          _drawerItem(Icons.shopping_cart_outlined, 'Subscribe'),
          _drawerItem(Icons.security, 'Data Privacy Declaration'),
          const Divider(),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.grey.shade700),
            title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
          _drawerItem(Icons.delete_outline, 'Delete Account'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {},
    );
  }
}
