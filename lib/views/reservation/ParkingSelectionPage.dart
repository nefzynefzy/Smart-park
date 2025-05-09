import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;

const Color primaryColor = Color(0xFF6A1B9A);
const Color secondaryColor = Color(0xFFD4AF37);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color textColor = Color(0xFF1E0D2B);
const Color subtitleColor = Color(0xFF757575);
const Color errorColor = Color(0xFFE57373);
const Color successColor = Color(0xFF81C784);
const Color whiteColor = Color(0xFFFFFFFF);
const Color grayColor = Color(0xFFEEEEEE);

class ParkingSelectionPage extends StatefulWidget {
  final String startTime;
  final String endTime;
  final String matricule;
  final int userId;

  const ParkingSelectionPage({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.matricule,
    required this.userId,
  });

  @override
  State<ParkingSelectionPage> createState() => _ParkingSelectionPageState();
}

class _ParkingSelectionPageState extends State<ParkingSelectionPage> {
  String? selectedSpotId;
  List<Map<String, dynamic>> parkingSpots = [];
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchParkingSpots();
  }

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token non trouvé');
      }
      return token;
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la récupération du token: $e';
      });
      return null;
    }
  }

  Future<void> _fetchParkingSpots() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de récupération du token';
      });
      return;
    }

    try {
      DateTime startDateTime;
      DateTime endDateTime;
      try {
        startDateTime = DateTime.parse(widget.startTime);
        endDateTime = DateTime.parse(widget.endTime);
      } catch (e) {
        startDateTime = DateTime.now();
        endDateTime = DateTime.now().add(const Duration(hours: 1));
        debugPrint('Invalid time format, using default: $e');
      }
      final date = startDateTime.toString().split(' ')[0];
      final startTime = "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}";
      final endTime = "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";

      final uri = Uri.parse('http://10.0.2.2:8082/parking/api/parking-spots/available')
          .replace(queryParameters: {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      });

      debugPrint('Fetching parking spots from: $uri');
      debugPrint('Authorization: Bearer $token');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Délai de connexion dépassé');
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> spots = json.decode(response.body);
        if (spots.isEmpty) {
          setState(() {
            parkingSpots = [];
            isLoading = false;
          });
          return;
        }

        setState(() {
          parkingSpots = spots.map((spot) {
            if (spot['id'] == null || spot['available'] == null) {
              throw Exception('Données de place de parking incomplètes: $spot');
            }
            return {
              'id': spot['id'].toString(),
              'status': spot['available'] == true ? 'available' : 'reserved',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur de récupération des places: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de récupération des places: $e';
        isLoading = false;
      });
    }
  }

  void selectSpot(String spotId) {
    setState(() {
      selectedSpotId = spotId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Choisir une place de parking',
          style: GoogleFonts.roboto(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 10),
            Text('Chargement', style: GoogleFonts.roboto(color: textColor)),
          ],
        ),
      )
          : Column(
        children: [
          if (errorMessage != null) _buildErrorMessage(errorMessage!),
          Expanded(
            child: parkingSpots.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_parking, size: 48, color: subtitleColor),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune place disponible',
                    style: GoogleFonts.roboto(color: subtitleColor, fontSize: 16),
                  ),
                ],
              ),
            )
                : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: parkingSpots.map((spot) {
                final isSelected = selectedSpotId == spot['id'];
                final isAvailable = spot['status'] == 'available';
                return GestureDetector(
                  onTap: isAvailable ? () => selectSpot(spot['id']) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? secondaryColor
                          : (isAvailable ? successColor : errorColor),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : grayColor,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_parking,
                          size: 40,
                          color: whiteColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSelected
                              ? 'Sélectionné\n${spot['id']}'
                              : (isAvailable ? 'Disponible\n${spot['id']}' : 'Réservé\n${spot['id']}'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            color: isSelected ? textColor : whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _buildLegend(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedSpotId != null
                  ? () {
                Navigator.pop(context, selectedSpotId);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: textColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Continuer',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: secondaryColor,
            label: 'Sélectionné',
            textColor: textColor,
          ),
          const SizedBox(width: 20),
          _LegendItem(
            color: successColor,
            label: 'Disponible (${parkingSpots.where((spot) => spot['status'] == 'available').length})',
            textColor: whiteColor,
          ),
          const SizedBox(width: 20),
          _LegendItem(
            color: errorColor,
            label: 'Réservé',
            textColor: whiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        border: Border.all(color: errorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.roboto(color: errorColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _LegendItem({required this.color, required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}