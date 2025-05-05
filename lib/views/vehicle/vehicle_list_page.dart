import 'package:flutter/material.dart';

class VehicleListPage extends StatelessWidget {
  const VehicleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> vehicles = [
      {'plate': '123-TN-456', 'brand': 'Toyota'},
      {'plate': '789-TN-012', 'brand': 'Hyundai'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mes véhicules')),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return ListTile(
            leading: const Icon(Icons.directions_car),
            title: Text(vehicle['plate']!),
            subtitle: Text(vehicle['brand']!),
          );
        },
      ),
    );
  }
}
