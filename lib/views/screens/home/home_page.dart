import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:borrow_manager/views/screens/clients/add_client_page.dart';
import 'package:borrow_manager/views/screens/clients/clients_list_page.dart';
import 'package:borrow_manager/views/screens/transactions/lend_borrow_page.dart';
import 'package:borrow_manager/views/screens/reminders/reminder_list_page.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';
import 'package:borrow_manager/data/models/client.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF13766D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TransactionViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(primaryTeal, vm),
                const SizedBox(height: 20),
                _buildActionGrid(context),
                const SizedBox(height: 20),
                _buildActiveContactsSection(vm),
                const SizedBox(height: 100), // Space for Bottom Nav
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(primaryTeal),
      floatingActionButton: _buildFAB(primaryTeal),
    );
  }

  Widget _buildTopSection(Color primaryTeal, TransactionViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          const Text(
            'Your Financial Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildFinancialOverviewRow(vm),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Color(0xFF13766D), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Borrow Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual profile image
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF13766D), width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialOverviewRow(TransactionViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildOverviewCard(
            'YOU GAVE',
            '₹${vm.totalLentBalance.toInt()}',
            Icons.call_made,
            Colors.black,
          ),
          const SizedBox(width: 15),
          _buildOverviewCard(
            'RECEIVED',
            '₹${vm.totalBorrowedBalance.toInt()}',
            Icons.call_received,
            Colors.black,
          ),
          const SizedBox(width: 15),
          _buildOverviewCard(
            'NET BALANCE',
            '₹${(vm.totalLentBalance - vm.totalBorrowedBalance).toInt()}',
            Icons.account_balance,
            Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String label, String amount, IconData icon, Color iconColor) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
        children: [
          _buildActionCard(
            context,
            'Manage Client',
            'Add or edit your existing debtors',
            Icons.person_add_alt_1_outlined,
            const ClientsListPage(),
          ),
          _buildActionCard(
            context,
            'Lend/Borrow',
            'Record new cash transactions',
            Icons.swap_horiz,
            const LendBorrowPage(),
          ),
          _buildActionCard(
            context,
            'Reminder List',
            'Set alerts for upcoming dues',
            Icons.notifications_none,
            const ReminderListPage(),
          ),
          _buildActionCard(
            context,
            'Full List',
            'View complete history log',
            Icons.group_outlined,
            const ClientsListPage(), // Replace with Full List page if exists
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF13766D), size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContactsSection(TransactionViewModel vm) {
    final upcomingTransactions = vm.transactions
        .where((t) => t.status == 'ACTIVE')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsListPage())),
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: Color(0xFF13766D))),
                    Icon(Icons.chevron_right, size: 18, color: Color(0xFF13766D)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (upcomingTransactions.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingTransactions.length > 3 ? 3 : upcomingTransactions.length,
              itemBuilder: (context, index) {
                final tx = upcomingTransactions[index];
                return _buildContactTile(tx);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, size: 40, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start by adding a client or\nrecording your first\nlend/borrow entry.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(dynamic tx) {
    return Consumer<ClientViewModel>(
      builder: (context, clientVm, child) {
        // Find the client object to get the imagePath
        final client = clientVm.clients.firstWhere(
          (c) => c.name == tx.clientName,
          orElse: () => Client(name: tx.clientName, phone: ''),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE0F2F1),
                backgroundImage: client.imagePath != null ? FileImage(File(client.imagePath!)) : null,
                child: client.imagePath == null ? const Icon(Icons.person, color: Color(0xFF13766D)) : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(tx.date)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${tx.remainingBalance.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tx.isLent ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(Color primaryTeal) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'Home', true, primaryTeal),
          _buildNavItem(Icons.group_outlined, 'Clients', false, primaryTeal),
          _buildNavItem(Icons.notifications_none, 'Alerts', false, primaryTeal, badge: '9'),
          _buildNavItem(Icons.settings_outlined, 'Settings', false, primaryTeal),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, Color primaryTeal, {String? badge}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Icon(icon, color: isSelected ? primaryTeal : Colors.grey, size: 26),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryTeal : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(Color primaryTeal) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClientPage())),
      backgroundColor: primaryTeal,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
