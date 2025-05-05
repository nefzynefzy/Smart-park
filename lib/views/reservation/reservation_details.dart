import 'package:flutter/material.dart';
import 'package:smart_parking/core/constants.dart';

class ReservationDetailsPage extends StatefulWidget {
  const ReservationDetailsPage({Key? key}) : super(key: key);

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  bool isActive = true; // Default to show active reservations
  List<Map<String, dynamic>> parkingSpots = [
    {'spot': 1, 'status': 'available'}, // Example spot data
    {'spot': 2, 'status': 'reserved'},
    {'spot': 3, 'status': 'available'},
    {'spot': 4, 'status': 'reserved'},
    {'spot': 5, 'status': 'available'},
  ];

  // Dummy Data for Active and Expired Reservations (This will come from your backend)
  final List<String> activeReservations = ["Spot 1", "Spot 2", "Spot 3"];
  final List<String> expiredReservations = ["Spot 4", "Spot 5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Détails de la Réservation",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons to toggle between active and expired reservations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isActive = true; // Show active reservations
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.primaryColor : AppColors.secondaryColor,
                  ),
                  child: Text("Réservations Actives"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isActive = false; // Show expired reservations
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.secondaryColor : AppColors.primaryColor,
                  ),
                  child: Text("Réservations Expirées"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Show Active or Expired Reservations based on selection
            Expanded(
              child: isActive ? _buildReservationList(activeReservations) : _buildReservationList(expiredReservations),
            ),

            const SizedBox(height: 20),
            // Parking Spot Grid
            Text(
              "Choisissez votre place de parking",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildParkingSpotGrid(),

            const SizedBox(height: 20),
            // Reservation Form
            ElevatedButton(
              onPressed: () {
                // Handle reservation submission
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              child: Text("Réserver"),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build reservation list
  Widget _buildReservationList(List<String> reservations) {
    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            reservations[index],
            style: TextStyle(fontSize: 18, color: AppColors.textColor),
          ),
          subtitle: Text("Véhicule : Véhicule ${index + 1}",
              style: TextStyle(color: AppColors.subtitleColor)),
        );
      },
    );
  }

  // Function to build parking spots grid
  Widget _buildParkingSpotGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: parkingSpots.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Handle tap on parking spot (if it's available)
            if (parkingSpots[index]['status'] == 'available') {
              print("Selected Spot: ${parkingSpots[index]['spot']}");
            } else {
              print("Spot is reserved.");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: parkingSpots[index]['status'] == 'available'
                  ? AppColors.greenColor
                  : AppColors.errorColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                AppIcons.parking,
                color: parkingSpots[index]['status'] == 'available'
                    ? AppColors.whiteColor
                    : AppColors.whiteColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire de Paiement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Détails du paiement", style: TextStyle(fontSize: 18)),
            // Here you can add payment form fields (Card details, Amount, etc.)
            ElevatedButton(
              onPressed: () {
                // Simulate payment process
                print("Payment Processed");
                Navigator.pop(context);
              },
              child: Text("Payer"),
            ),
          ],
        ),
      ),
    );
  }
}
