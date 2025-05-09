import 'package:flutter/material.dart';
import 'package:smart_parking/core/constants.dart';
import 'package:smart_parking/views/reservation/reservation_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';

class BottomSheetInfo extends StatelessWidget {
  final String spotId;
  final double distance;
  final double costPerHour;

  const BottomSheetInfo({
    super.key,
    required this.spotId,
    required this.distance,
    required this.costPerHour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, -3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spot ID: $spotId",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            "Distance: ${distance.toStringAsFixed(0)}m",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "Coût: ${costPerHour.toStringAsFixed(2)} DT/hr",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReservationPage()),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add, color: AppColors.textColor),
                  label: const Text("Réserver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: AppColors.textColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScanVehiclePage()),
                    );
                  },
                  icon: const Icon(AppIcons.scan, color: AppColors.primaryColor),
                  label: const Text("Scanner"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}