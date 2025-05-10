import 'package:flutter/material.dart';
import '../constants.dart';

class MainLayout extends StatelessWidget {
  final String userName;
  final bool isDarkMode;
  final VoidCallback toggleDarkMode;
  final int currentIndex;
  final Function(int) onNavTap;
  final Widget child;

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
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : AppColors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
              color: isDarkMode ? AppColors.whiteColor : AppColors.textColor,
            ),
            onPressed: toggleDarkMode,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onNavTap(4), // ProfilePage at index 4
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDarkMode ? AppColors.primaryDarkColor : AppColors.accentLightColor,
                child: Icon(
                  Icons.person, // Profile icon
                  color: isDarkMode ? AppColors.whiteColor : AppColors.textColor,
                  size: 24, // Adjust size as needed
                ),
              ),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 70,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primaryDarkColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
            _buildNavItem(Icons.qr_code_2, 'Scan', 2), // Added QR code scanning item
            _buildNavItem(Icons.subscriptions, 'Subscription', 3),
          ],
        ),
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
            color: currentIndex == index
                ? AppColors.secondaryColor
                : (isDarkMode ? AppColors.accentLightColor : AppColors.subtitleColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: currentIndex == index
                  ? AppColors.secondaryColor
                  : (isDarkMode ? AppColors.accentLightColor : AppColors.subtitleColor),
            ),
          ),
        ],
      ),
    );
  }
}