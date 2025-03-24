import 'package:flutter/material.dart';
import '../screens/reservation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profil_screen.dart';


class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  _AbonnementScreenState createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home_screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/reservation_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/abonnement_screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil_screen');
        break;
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonnement"),
        backgroundColor: Colors.purple,


      ),

      body: Center(child: Text("Page d'abonnement")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Réservation"),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: "Abonnement"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}