import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/language_provider.dart';

class SubscribePage extends StatelessWidget {
  const SubscribePage({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBg = Color(0xFF0F172A);
    const slate400 = Color(0xFF94A3B8);
    const slate500 = Color(0xFF64748B);
    const slate800 = Color(0xFF1E293B);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('Premium Access', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: goldColor.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.workspace_premium_rounded, size: 100, color: goldColor),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upgrade to Pro',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take your money management to the next level with professional tools.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: slate400,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureRow(Icons.block_rounded, 'No Ads', 'Clean, distraction-free experience', slate400),
                  const SizedBox(height: 24),
                  _buildFeatureRow(Icons.picture_as_pdf_rounded, 'Export PDF', 'Share professional reports with clients', slate400),
                  const SizedBox(height: 24),
                  _buildFeatureRow(Icons.cloud_sync_rounded, 'Real-time Sync', 'Automated cloud backups every hour', slate400),
                  const SizedBox(height: 24),
                  _buildFeatureRow(Icons.palette_rounded, 'Custom Themes', 'Personalize your app appearance', slate400),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPackageCard('ANNUAL PASS', '₹100', 'per year', goldColor, true, slate400, slate500, slate800),
                  const SizedBox(height: 16),
                  _buildPackageCard('QUARTERLY', '₹30', '3 months', slate400, false, slate400, slate500, slate800),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Secure Payment via Google Play',
              style: TextStyle(color: slate500, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle, Color slate400) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF818CF8), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: TextStyle(color: slate400, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(String title, String price, String period, Color accent, bool isPopular, Color slate400, Color slate500, Color slate800) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPopular ? accent : slate800, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                    child: const Text('BEST VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                Text(title, style: TextStyle(color: isPopular ? Colors.white : slate400, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text(period, style: TextStyle(color: slate500, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isPopular ? accent : Colors.white10,
              foregroundColor: isPopular ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
