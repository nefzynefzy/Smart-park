import 'package:flutter/material.dart';
import 'package:smart_parking/views/home/home_page.dart';
import 'package:smart_parking/views/profile/profile_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';
import 'package:smart_parking/views/reservation/reservation_details.dart'; // Update import
import 'package:smart_parking/views/menu/menu_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Update this list to include the new page
  final List<Widget> _pages = const [
    HomePage(),
    ReservationDetailsPage(), // This will be displayed when 'Réservations' is tapped
    ScanVehiclePage(),
    MenuPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // This is where the selected page is rendered
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index), // When an item is tapped, the page is changed
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Réservations'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
