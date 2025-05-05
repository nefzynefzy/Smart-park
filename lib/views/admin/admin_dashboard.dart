import 'package:flutter/material.dart';
import 'package:smart_parking/widgets/custom_button.dart';
import 'package:smart_parking/widgets/parking_spot_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.lightBlue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          Text("Total Spots", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text("120", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: const [
                          Text("Active Reservations", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text("47", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: "Manage Parking Spots",
              icon: Icons.local_parking,
              onPressed: () {
                // TODO: Navigate to parking spot management page
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: "View Reservation Logs",
              icon: Icons.list_alt,
              onPressed: () {
                // TODO: Navigate to logs or reservations list
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: "Log Out",
              icon: Icons.logout,
              color: Colors.redAccent,
              onPressed: () {
                // TODO: Implement logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
