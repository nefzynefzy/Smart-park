import 'package:flutter/material.dart';

class LanguagePreferencesPage extends StatelessWidget {
  const LanguagePreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Préférences de Langue',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: const Center(
        child: Text(
          'Préférences de langue à implémenter',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}