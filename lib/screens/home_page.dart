import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import '../services/language_provider.dart';
import '../services/google_drive_service.dart';
import 'add_client_page.dart';
import 'clients_list_page.dart';
import 'lend_borrow_page.dart';
import 'reminder_list_page.dart';
import 'subscribe_page.dart';
import 'settings_dialog.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userMobile;

  const HomePage({
    super.key,
    this.userName = 'User',
    this.userEmail = '',
    this.userMobile = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _totalGave = 0.0;
  double _totalReceived = 0.0;
  bool _isGoogleConnected = false;
  String _displayName = 'User';
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _checkGoogleStatus();
  }

  Future<void> _refreshData() async {
    await _loadBalances();
    await _loadUserData();
    await _loadRecentTransactions();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _displayName = prefs.getString('userName') ?? widget.userName;
      });
    }
  }

  Future<void> _checkGoogleStatus() async {
    final account = await GoogleDriveService.signInSilently();
    if (mounted) {
      setState(() {
        _isGoogleConnected = account != null;
      });
    }
  }

  Future<void> _loadRecentTransactions() async {
    final data = await DatabaseHelper().queryAllTransactions();
    // Sort by date descending and take top 5
    List<Map<String, dynamic>> sorted = List.from(data);
    sorted.sort((a, b) => b['date'].compareTo(a['date']));
    if (mounted) {
      setState(() {
        _recentTransactions = sorted.take(5).toList();
      });
    }
  }

  Future<void> _loadBalances() async {
    final transactions = await DatabaseHelper().queryAllTransactions();
    double gave = 0.0;
    double received = 0.0;

    for (var t in transactions) {
      if (t['isLent'] == 1) {
        gave += t['amount'];
      } else {
        received += t['amount'];
      }
    }

    if (mounted) {
      setState(() {
        _totalGave = gave;
        _totalReceived = received;
      });
    }
  }

  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Backup'),
        content: const Text('Keep your data safe by syncing with Google Drive.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await GoogleDriveService.backupDatabase();
              if (success) {
                _checkGoogleStatus();
                if (mounted) _showSnackBar('Backup Successful', Colors.green);
              } else {
                if (mounted) _showSnackBar('Backup Failed', Colors.red);
              }
            },
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _totalReceived - _totalGave;
    final lang = Provider.of<LanguageProvider>(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello,', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
            Text(_displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReminderListPage())),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userName: _displayName, userEmail: widget.userEmail, userMobile: widget.userMobile))).then((_) => _refreshData()),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline, size: 20, color: primaryColor),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, primaryColor, lang),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildBalanceCard(balance, lang, primaryColor),
            const SizedBox(height: 32),
            _buildSectionHeader(lang.translate('quick_actions'), null),
            _buildQuickActions(context),
            const SizedBox(height: 32),
            _buildSectionHeader('Financial Summary', null),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            _buildSectionHeader('Recent Activity', 'See logs'),
            _buildRecentActivityList(),
            const SizedBox(height: 32),
            _buildSectionHeader('Cloud Sync', null),
            _buildCloudStatusCard(),
            const SizedBox(height: 20),
            _buildPremiumBanner(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LendBorrowPage())).then((_) => _refreshData()),
        label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded, size: 28),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBalanceCard(double balance, LanguageProvider lang, Color primary) {
    bool isPositive = balance >= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive 
            ? [const Color(0xFF6366F1), const Color(0xFF818CF8)] 
            : [const Color(0xFFF43F5E), const Color(0xFFFB7185)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? const Color(0xFF6366F1) : const Color(0xFFF43F5E)).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${balance.abs().toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                isPositive ? 'You are owed overall' : 'You owe overall',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (_recentTransactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text('No recent transactions', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ),
      );
    }

    return Column(
      children: _recentTransactions.map((tx) {
        bool isGave = tx['isLent'] == 1;
        DateTime date = DateTime.parse(tx['date']);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isGave ? const Color(0xFFF43F5E) : const Color(0xFF10B981)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGave ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isGave ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['clientName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                    Text(DateFormat('dd MMM, hh:mm a').format(date), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ),
              Text(
                '₹${tx['amount']}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isGave ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          if (actionText != null)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LendBorrowPage())).then((_) => _refreshData()),
              child: Text(actionText, style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildActionCard(context, 'Add Client', Icons.person_add_alt_1_rounded, const Color(0xFF8B5CF6), const AddClientPage()),
          _buildActionCard(context, 'Client List', Icons.people_rounded, const Color(0xFF3B82F6), const ClientsListPage()),
          _buildActionCard(context, 'History', Icons.receipt_long_rounded, const Color(0xFF10B981), const LendBorrowPage()),
          _buildActionCard(context, 'Reminders', Icons.alarm_on_rounded, const Color(0xFFF59E0B), const ReminderListPage()),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)).then((_) => _refreshData()),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem('Gave (Lent)', '₹$_totalGave', Icons.arrow_upward_rounded, const Color(0xFFF43F5E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryItem('Got (Borrowed)', '₹$_totalReceived', Icons.arrow_downward_rounded, const Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildCloudStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isGoogleConnected ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isGoogleConnected ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _isGoogleConnected ? Colors.green : Colors.orange,
            child: Icon(_isGoogleConnected ? Icons.cloud_done : Icons.cloud_off, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isGoogleConnected ? 'Cloud Sync Active' : 'Offline Mode',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                ),
                Text(
                  _isGoogleConnected ? 'Your data is secured' : 'Backup now to avoid data loss',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showBackupRestoreDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isGoogleConnected ? Colors.green : Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sync', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Go Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Unlock advanced reports, custom themes and ad-free experience.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscribePage())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
                  child: const Text('Upgrade Now'),
                ),
              ],
            ),
          ),
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4AF37), size: 60),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Color primary, LanguageProvider lang) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            width: double.infinity,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 35, backgroundColor: primary, child: const Icon(Icons.person, color: Colors.white, size: 40)),
                const SizedBox(height: 16),
                Text(_displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.userEmail.isEmpty ? 'Offline Profile' : widget.userEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', () => showDialog(context: context, builder: (ctx) => const SettingsDialog())),
          _buildDrawerItem(Icons.security_outlined, 'Backup & Security', _showBackupRestoreDialog),
          _buildDrawerItem(Icons.star_outline_rounded, 'Rate App', () {}),
          _buildDrawerItem(Icons.help_outline_rounded, 'Support', () {}),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('Version 2.0.0', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF475569)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
