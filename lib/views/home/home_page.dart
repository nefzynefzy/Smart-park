// home_page.dart
import 'package:flutter/material.dart';
import 'package:smart_parking/core/layout/main_layout.dart';
import 'package:smart_parking/views/profile/profile_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';
import 'package:smart_parking/views/reservation/reservation_page.dart';
import 'package:smart_parking/views/menu/menu_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool isDarkMode = false;
  final String userName = "Sami";

  static const LatLng technopoleLatLng = LatLng(36.808437, 10.097780);

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 1:
        return ReservationPage(); // Remove the 'const' here
      case 2:
        return ScanVehiclePage(); // Remove the 'const' here
      case 3:
        return ProfilePage(); // Remove the 'const' here
      case 4:
        return MenuPage(); // Remove the 'const' here
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Ahla bik, $userName 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Nawwart Parkiny! 🚗',
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 500,
            child: FlutterMap(
              options: const MapOptions(center: technopoleLatLng, zoom: 16.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: technopoleLatLng,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _onNavTap(1),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFF59D),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
          ),
          child: const Text(
            'Réserver ma place',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      userName: userName,
      isDarkMode: isDarkMode,
      toggleDarkMode: () => setState(() => isDarkMode = !isDarkMode),
      currentIndex: _currentIndex,
      onNavTap: _onNavTap,
      child: _getCurrentPage(),
    );
  }
}
