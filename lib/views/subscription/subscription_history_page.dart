import 'package:flutter/material.dart';

class SubscriptionHistoryPage extends StatelessWidget {
  const SubscriptionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Historique des Abonnements',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: const Center(
        child: Text(
          'Historique des abonnements à implémenter',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}