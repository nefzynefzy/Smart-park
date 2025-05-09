import 'package:flutter/material.dart';
import 'package:smart_parking/views/home/home_page.dart';
import 'package:smart_parking/views/profile/profile_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';
import 'package:smart_parking/views/reservation/reservation_details.dart';
import 'package:smart_parking/views/subscription/subscription_page.dart';
import 'package:smart_parking/views/vehicle/add_vehicle_page.dart' hide SubscriptionPage;
import 'core/layout/main_layout.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),              // Index 0: Accueil
    ReservationDetailsPage(), // Index 1: Réservation
    ScanVehiclePage(),       // Index 2: Scan (QR code)
    SubscriptionPage(),      // Index 3: Subscription
    ProfilePage(),           // Index 4: Profile (via AppBar avatar)
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      userName: "User",
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      toggleDarkMode: () {
        // Toggle theme mode logic here if needed
      },
      currentIndex: _selectedIndex,
      onNavTap: (index) => setState(() => _selectedIndex = index),
      child: _pages[_selectedIndex],
    );
  }
}