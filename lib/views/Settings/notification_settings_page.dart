import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Paramètres de Notification',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: const Center(
        child: Text(
          'Paramètres de notification à implémenter',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}