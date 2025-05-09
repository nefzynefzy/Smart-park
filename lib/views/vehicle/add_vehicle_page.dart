import 'package:flutter/material.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Mon Abonnement',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: const Center(
        child: Text(
          'Détails de l’abonnement à implémenter',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}