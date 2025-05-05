import 'package:flutter/material.dart';
import 'package:smart_parking/core/constants.dart';
import 'package:smart_parking/widgets/primary_button.dart';


class BottomSheetInfo extends StatelessWidget {
  const BottomSheetInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spot ID: A12",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("Distance: 200m"),
          const Text("Cost: 1.50 DT/hr"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: "Réserver",
                  icon: Icons.bookmark_add,
                  onPressed: () {
                    // Implement reservation
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Implement scan
                  },
                  icon: const Icon(AppIcons.scan, color: Color(0xFFFFA726)),
                  label: const Text("Scanner"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFA726),
                    side: const BorderSide(color: Color(0xFFFFA726)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
