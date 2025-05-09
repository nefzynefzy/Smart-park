import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_parking/core/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ReservationDetailsPage extends StatefulWidget {
  const ReservationDetailsPage({Key? key}) : super(key: key);

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  bool isActive = true;
  List<Map<String, dynamic>> activeReservations = [];
  List<Map<String, dynamic>> expiredReservations = [];
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la récupération du token: $e';
      });
      return null;
    }
  }

  Future<void> _fetchReservations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de récupération des réservations';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Erreur de récupération des réservations');
      });

      if (response.statusCode == 200) {
        final userProfile = json.decode(response.body);
        final List<dynamic> reservations = userProfile['reservationHistory'] ?? [];

        final List<Map<String, dynamic>> tempActive = [];
        final List<Map<String, dynamic>> tempExpired = [];
        final now = DateTime.now();

        for (var res in reservations) {
          final endTime = DateTime.parse(res['endTime']);
          final reservation = {
            'parkingSpotId': res['parkingSpotId'].toString(),
            'startTime': DateTime.parse(res['startTime']),
            'endTime': endTime,
            'status': res['status'],
            'totalCost': res['totalCost']?.toString() ?? 'N/A',
          };

          if (endTime.isAfter(now) && res['status'] == 'PENDING') {
            tempActive.add(reservation);
          } else {
            tempExpired.add(reservation);
          }
        }

        setState(() {
          activeReservations = tempActive;
          expiredReservations = tempExpired;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur de récupération des réservations: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de récupération des réservations: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Détails de la Réservation",
          style: GoogleFonts.poppins(
            color: AppColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 10),
            Text(
              'Chargement',
              style: GoogleFonts.poppins(color: AppColors.textColor),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  border: Border(
                    left: BorderSide(color: AppColors.errorColor, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AppColors.errorColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(color: AppColors.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isActive = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.primaryColor : AppColors.grayColor,
                    foregroundColor: isActive ? AppColors.whiteColor : AppColors.textColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Réservations Actives",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.whiteColor : AppColors.textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isActive = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? AppColors.grayColor : AppColors.primaryColor,
                    foregroundColor: isActive ? AppColors.textColor : AppColors.whiteColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Réservations Expirées",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.textColor : AppColors.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Reservation List
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: isActive
                    ? _buildReservationList(activeReservations)
                    : _buildReservationList(expiredReservations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationList(List<Map<String, dynamic>> reservations) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: AppColors.subtitleColor),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Aucune réservation active' : 'Aucune réservation expirée',
              style: GoogleFonts.poppins(
                color: AppColors.subtitleColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_parking, color: AppColors.primaryColor),
            ),
            title: Text(
              'Place ${reservation['parkingSpotId']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Début: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation['startTime'])}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.subtitleColor,
                  ),
                ),
                Text(
                  'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(reservation['endTime'])}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.subtitleColor,
                  ),
                ),
                Text(
                  'Coût: ${reservation['totalCost']} DT',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.subtitleColor,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              reservation['status'] == 'PENDING' ? Icons.access_time : Icons.check_circle,
              color: reservation['status'] == 'PENDING' ? AppColors.secondaryColor : AppColors.successColor,
            ),
          ),
        );
      },
    );
  }
}