import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'payment_detail_screen.dart';
import '../utils/currency_utils.dart'; 

class PaymentOfferScreen extends StatelessWidget {
  const PaymentOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: const CustomAppBar(
        title: 'Penawaran Paket',
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF012D5A),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildOfferCard(
              context,
              title: '🚀 Paket Premium',
              desc: 'Akses penuh semua materi dan kuis eksklusif.',
              price: 15000,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String desc,
    required double price,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF012D5A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            CurrencyUtils.format(price, 'IDR'),
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PaymentDetailScreen(planName: title, price: price),
                ),
              );
            },
            child: const Text("Beli Sekarang"),
          ),
        ],
      ),
    );
  }
}
