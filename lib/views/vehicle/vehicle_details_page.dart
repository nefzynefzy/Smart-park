import 'package:flutter/material.dart';

class VehicleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: Text(
          '${vehicle['brand'] ?? 'N/A'} ${vehicle['model'] ?? 'N/A'}',
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matricule: ${vehicle['matricule'] ?? 'N/A'}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Type: ${vehicle['vehicleType'] ?? 'N/A'}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            Text(
              'Couleur: ${vehicle['color'] ?? 'N/A'}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}