import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final String userName;
  final bool isDarkMode;
  final VoidCallback toggleDarkMode;
  final int currentIndex;
  final Function(int) onNavTap;
  final Widget child;

  static const Color secondaryColor = Color(0xFFFFA726); // Orange
  static const Color accentLightColor = Color(0xFFFFF59D); // Pale Yellow

  const MainLayout({
    super.key,
    required this.userName,
    required this.isDarkMode,
    required this.toggleDarkMode,
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: toggleDarkMode,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onNavTap(3),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDarkMode ? Colors.grey[800] : accentLightColor,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 70,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Accueil', 0),
                _buildNavItem(Icons.event_note_outlined, 'Réservation', 1),
                const SizedBox(width: 56), // Space for central button
                _buildNavItem(Icons.payment_outlined, 'Paiement', 3),
                _buildNavItem(Icons.menu, 'Menu', 4),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: FloatingActionButton(
              onPressed: () => onNavTap(2),
              backgroundColor: secondaryColor,
              elevation: 6,
              child: const Icon(Icons.qr_code_2, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: currentIndex == index ? secondaryColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: currentIndex == index ? secondaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
