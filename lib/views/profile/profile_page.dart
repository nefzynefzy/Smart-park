import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(height: 20),
            Text('Maryem Bejaoui', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('maryem@example.com', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
