import 'package:flutter/material.dart';

class ScanVehiclePage extends StatelessWidget {
  const ScanVehiclePage({super.key});

  void _simulateScan(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Plaque détectée'),
        content: const Text('Numéro: 123-TN-456'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Vehicle')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _simulateScan(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scanner la plaque'),
        ),
      ),
    );
  }
}
