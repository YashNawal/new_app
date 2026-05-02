import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:borrow_manager/views/screens/clients/add_client_page.dart';
import 'package:borrow_manager/views/screens/clients/clients_list_page.dart';
import 'package:borrow_manager/views/screens/transactions/lend_borrow_page.dart';
import 'package:borrow_manager/views/screens/reminders/reminder_list_page.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';

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
    const primaryGreen = Color(0xFF004D40);
    const darkGreen = Color(0xFF002420);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen, darkGreen],
          ),
        ),
        child: SafeArea(
          child: Consumer<TransactionViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  _buildHeader(widget.userName),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildSummaryRow(vm),
                          const SizedBox(height: 20),
                          _buildActionGrid(context),
                          const SizedBox(height: 20),
                          _buildContactsSection(vm),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white70),
            onPressed: () {},
          ),
          const Text(
            'Borrow Manager',
            style: TextStyle(
              color: Color(0xFFFFD740),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: ClipOval(
              child: Icon(Icons.person, color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(TransactionViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryCard(
            'Gave',
            '₹${vm.totalLentBalance.toStringAsFixed(2)}',
            Colors.redAccent.shade100,
            Icons.arrow_upward,
          ),
          _buildSummaryCard(
            'Received',
            '₹${vm.totalBorrowedBalance.toStringAsFixed(2)}',
            Colors.greenAccent.shade400,
            Icons.arrow_downward,
            isCenter: true,
          ),
          _buildSummaryCard(
            'Balance',
            '₹${(vm.totalLentBalance - vm.totalBorrowedBalance).toStringAsFixed(2)}',
            const Color(0xFFFFD740),
            null,
            subtitle: 'Positive',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String amount, Color color, IconData? icon,
      {bool isCenter = false, String? subtitle}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(height: 4),
            Icon(icon, color: color.withOpacity(0.7), size: 16),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ]
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(
            'Manage\nClient',
            'assets/images/add_client.png',
            const AddClientPage(),
          ),
          _buildActionCard(
            'Lend/\nBorrow',
            'assets/images/lend_borrow.png',
            const LendBorrowPage(),
          ),
          _buildActionCard(
            'Reminder\nList',
            'assets/images/reminder.png',
            const ReminderListPage(),
          ),
          _buildActionCard(
            'Client\nList',
            'assets/images/client_list.png',
            const ClientsListPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String imagePath, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF004D40),
                ),
              ),
            ),
            Image.asset(
              imagePath,
              width: 45,
              height: 45,
              errorBuilder: (c, e, s) => const Icon(Icons.image, color: Color(0xFF00897B), size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsSection(TransactionViewModel vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 16),
          if (vm.transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No active transactions', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.transactions.length,
              itemBuilder: (context, index) {
                final tx = vm.transactions[index];
                return _buildContactCard(tx);
              },
            ),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildContactCard(dynamic tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF002420),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00897B), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.person, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.clientName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text(
                      'Mobile: +1-8965990868', // Mock data for now
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Client #8532',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Contract ID:', '2FFD0S23'),
              _buildStatusLabel('Active'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Requiring payments (1H)', ''),
              _buildDetailItem('Interest Rate =', '${tx.interestRate}%', isGold: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(Icons.access_time, 'Due:', '₹${tx.remainingBalance}'),
              _buildMetricItem(Icons.calendar_today, 'Next:', DateFormat('dd-MM-yyyy').format(tx.date)),
              _buildMetricItem(Icons.note_alt_outlined, 'Remark:', 'Project Loan'),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar('Due:', 100, Colors.greenAccent),
          const SizedBox(height: 8),
          _buildProgressBar('Reminder:', 90, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isGold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        if (value.isNotEmpty)
          Text(
            value,
            style: TextStyle(
              color: isGold ? const Color(0xFFFFD740) : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusLabel(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFFFFD740)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
        Text(value, style: const TextStyle(color: Color(0xFFFFD740), fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10))),
        Expanded(
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white10,
            color: color.withOpacity(0.6),
            minHeight: 4,
          ),
        ),
        const SizedBox(width: 10),
        Text('$progress%', style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.bar_chart, color: Color(0xFF004D40)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.grey), onPressed: () {}),
          const SizedBox(width: 40), // Space for FAB
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.grey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.grey), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF00897B).withOpacity(0.4),
            const Color(0xFF00897B).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddClientPage())),
          backgroundColor: const Color(0xFF004D40),
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00897B).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
