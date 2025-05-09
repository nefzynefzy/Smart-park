import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Paramètres de Confidentialité',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: const Center(
        child: Text(
          'Paramètres de confidentialité à implémenter',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}