import 'package:flutter/material.dart';
import 'package:smart_parking/core/layout/main_layout.dart';
import 'package:smart_parking/views/profile/profile_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';
import 'package:smart_parking/views/reservation/reservation_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_parking/core/constants.dart';
import 'package:smart_parking/views/subscription/subscription_page.dart';
import 'package:smart_parking/views/vehicle/add_vehicle_page.dart' hide SubscriptionPage;

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
        return ReservationPage(); // Index 1: Réservation
      case 2:
        return ScanVehiclePage(); // Index 2: Scan (QR code)
      case 3:
        return SubscriptionPage(); // Index 3: Subscription
      case 4:
        return ProfilePage();     // Index 4: Profile (via AppBar avatar)
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor.withOpacity(0.85),
                    AppColors.darkBackgroundColor.withOpacity(0.95),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ahla bik, $userName 👋',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 28,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nawwart Parkiny! 🚗',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.accentLightColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _onNavTap(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Réserver ma place',
                      style: TextStyle(fontSize: 16, color: AppColors.textColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentLightColor, width: 2),
            ),
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
                      child: const Icon(Icons.location_on, color: AppColors.secondaryColor, size: 40),
                    ),
                  ],
                ),
              ],
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