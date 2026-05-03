import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:borrow_manager/data/models/client.dart';
import 'package:borrow_manager/data/models/transaction.dart';
import 'package:borrow_manager/viewmodels/transaction_viewmodel.dart';
import 'package:borrow_manager/viewmodels/client_viewmodel.dart';

class ClientDetailPage extends StatefulWidget {
  final Client client;
  const ClientDetailPage({super.key, required this.client});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  bool _isEditExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().fetchTransactions();
    });
  }

  void _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendSMS(String phone) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _sendWhatsApp(String phone) async {
    String url = "https://wa.me/$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF7E57C2);
    const lightGrey = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('PROFILE VIEW', style: TextStyle(fontSize: 10, letterSpacing: 1.2)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, txVm, child) {
          final clientTransactions = txVm.transactions.where((t) => t.clientName == widget.client.name).toList();
          
          double totalLent = clientTransactions.where((t) => t.isLent).fold(0, (sum, t) => sum + t.principal);
          double totalBorrowed = clientTransactions.where((t) => !t.isLent).fold(0, (sum, t) => sum + t.principal);
          double currentBalance = totalLent - totalBorrowed;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildIdentityCard(widget.client, primaryPurple),
                _buildFinancialSummary(currentBalance, totalLent, totalBorrowed),
                _buildMainActions(context),
                _buildTransactionsSection(clientTransactions),
                _buildDocumentsSection(),
                _buildEditSection(primaryPurple),
                _buildQuickTemplates(widget.client),
                _buildDangerZone(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdentityCard(Client client, Color primaryPurple) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: client.imagePath != null ? FileImage(File(client.imagePath!)) : null,
                    child: client.imagePath == null ? const Icon(Icons.person, size: 35) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(client.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    Text('ID: CM-${client.id.toString().padLeft(6, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionBtn(Icons.call, 'Call', () => _makeCall(client.phone)),
              _buildQuickActionBtn(Icons.chat_bubble_outline, 'SMS', () => _sendSMS(client.phone)),
              _buildQuickActionBtn(Icons.send, 'WhatsApp', () => _sendWhatsApp(client.phone)),
              const VerticalDivider(),
              _buildQuickActionBtn(Icons.notifications_none, 'Remind', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3E5F5), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF7E57C2), size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(double balance, double lent, double borrowed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Financial Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('View Trends', style: TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryCard('BALANCE', '₹${balance.toInt()}', const Color(0xFFF8F9FA), Colors.black, Icons.north_east),
                _buildSummaryCard('TOTAL LENT', '₹${lent.toInt()}', const Color(0xFFEDE7F6), Colors.deepPurple, null),
                _buildSummaryCard('TOTAL BORROW', '₹${borrowed.toInt()}', const Color(0xFFFFEBEE), Colors.redAccent, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String amount, Color bg, Color textColor, IconData? icon) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null) Icon(icon, size: 14, color: Colors.grey),
              const Icon(Icons.help_outline, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildActionBtn(Icons.add, 'Add Transaction', const Color(0xFF7E57C2), Colors.white, () {})),
              const SizedBox(width: 12),
              Expanded(child: _buildActionBtn(Icons.file_download_outlined, 'Export Statement', Colors.white, Colors.black87, () {})),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionBtn(Icons.notifications_none, 'Set Reminder', Colors.white, Colors.black87, () {})),
              const SizedBox(width: 12),
              Expanded(child: _buildActionBtn(Icons.message_outlined, 'Message', Colors.white, Colors.black87, () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color bg, Color text, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: text,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: bg == Colors.white ? BorderSide(color: Colors.grey.shade300) : BorderSide.none),
        elevation: 0,
      ),
    );
  }

  Widget _buildTransactionsSection(List<Transaction> transactions) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transactions', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Icon(Icons.tune, size: 20, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Row
          Row(
            children: [
              _buildSmallChip('All', true),
              _buildSmallChip('Lone', false),
              _buildSmallChip('Borrowed', false),
              _buildSmallChip('Settled', false),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTxCard(tx);
            },
          ),
          TextButton(onPressed: () {}, child: const Text('View All Transactions', style: TextStyle(color: Colors.deepPurple, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isSelected ? Colors.deepPurple : Colors.white, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTxCard(Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: tx.isLent ? Colors.blue.shade50 : Colors.red.shade50, shape: BoxShape.circle),
            child: Icon(tx.isLent ? Icons.north_east : Icons.south_west, size: 16, color: tx.isLent ? Colors.blue : Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.isLent ? 'Loan given' : 'Loan received', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(DateFormat('MMM dd, yyyy').format(tx.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${tx.isLent ? '+' : '-'}₹${tx.principal.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tx.isLent ? Colors.green : Colors.red)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                child: const Text('Due', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildDocActionBtn(Icons.camera_alt_outlined, 'Photo'),
                  const SizedBox(width: 10),
                  _buildDocActionBtn(Icons.upload_outlined, 'Upload'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDocThumbnail('Contract_A.pdf', Icons.picture_as_pdf, Colors.blue.shade50),
                _buildDocThumbnail('Receipt_042.jpg', Icons.image_outlined, Colors.orange.shade50),
                _buildDocThumbnail('Identity_Proof.jpg', Icons.badge_outlined, Colors.green.shade50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocActionBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDocThumbnail(String name, IconData icon, Color bg) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 30, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEditSection(Color primaryPurple) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: const Text('Edit Client Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: const Text('Manage profile, address & preferences', style: TextStyle(fontSize: 10, color: Colors.grey)),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.settings_outlined, color: Colors.deepPurple, size: 20)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: primaryPurple), child: const Text('Save Changes', style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates(Client client) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Templates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(12)), child: const Text('PAYMENT REMINDER', style: TextStyle(color: Colors.deepPurple, fontSize: 8, fontWeight: FontWeight.bold))),
                    const Icon(Icons.share_outlined, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Hi ${client.name}, this is a friendly reminder for ₹12,500 due on Oct 24, 2023. Kindly settle...', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.send, size: 14), label: const Text('WhatsApp', style: TextStyle(fontSize: 12)))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, size: 14), label: const Text('SMS', style: TextStyle(fontSize: 12)))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.shade100)),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.error_outline, color: Colors.red, size: 20)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Danger Zone', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text('Deleting this client will permanently erase all transaction history.', style: TextStyle(fontSize: 10, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              label: const Text('Delete Client & Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
