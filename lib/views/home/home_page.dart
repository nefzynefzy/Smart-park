import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_parking/core/layout/main_layout.dart';
import 'package:smart_parking/views/profile/profile_page.dart';
import 'package:smart_parking/views/scan/scan_vehicle_page.dart';
import 'package:smart_parking/views/reservation/reservation_page.dart';
import 'package:smart_parking/views/subscription/subscription_page.dart';
import 'package:smart_parking/views/vehicle/add_vehicle_page.dart' hide SubscriptionPage;

const Color primaryColor = Color(0xFF6A1B9A);
const Color secondaryColor = Color(0xFFD4AF37);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color textColor = Color(0xFF1E0D2B);
const Color subtitleColor = Color(0xFF757575);
const Color errorColor = Color(0xFFE57373);
const Color successColor = Color(0xFF81C784);
const Color whiteColor = Color(0xFFFFFFFF);
const Color grayColor = Color(0xFFEEEEEE);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool isDarkMode = false;
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> parkingSpots = [];
  bool isLoading = true;
  String? errorMessage;

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
      final startDateTime = DateTime.now();
      final endDateTime = DateTime.now().add(const Duration(hours: 1));
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
        setState(() {
          parkingSpots = spots.take(6).map((spot) {
            // Limit to first 6 spots
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
        return ProfilePage(); // Index 4: Profile
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Welcome message
        Text(
          'Bienvenue à Parkiny!',
          style: GoogleFonts.roboto(
            fontSize: 28,
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: grayColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un emplacement',
              hintStyle: GoogleFonts.roboto(color: subtitleColor),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Parking spots grid
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: primaryColor))
        else if (errorMessage != null)
          Center(
            child: Text(
              errorMessage!,
              style: GoogleFonts.roboto(color: errorColor),
              textAlign: TextAlign.center,
            ),
          )
        else if (parkingSpots.isEmpty)
            Center(
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
          else
            Column(
              children: [
                Text(
                  'Plan du parking',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: grayColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int row = 0; row < 2; row++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int col = 0; col < 3; col++)
                              Builder(
                                builder: (_) {
                                  int index = row * 3 + col;
                                  if (index >= parkingSpots.length) return const SizedBox(width: 60, height: 60);

                                  final spot = parkingSpots[index];
                                  final isAvailable = spot['status'] == 'available';
                                  return Column(
                                    children: [
                                      Icon(
                                        Icons.local_parking,
                                        size: 40,
                                        color: isAvailable ? successColor : errorColor,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'S${spot['id']}',
                                        style: GoogleFonts.roboto(
                                          color: textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

        const SizedBox(height: 24),
        // Réserver maintenant button
        Padding(
          padding: const EdgeInsets.only(bottom: 80.0), // Avoid nav bar overlap
          child: ElevatedButton(
            onPressed: parkingSpots.any((spot) => spot['status'] == 'available')
                ? () => _onNavTap(1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              shadowColor: grayColor.withOpacity(0.4),
              minimumSize: const Size(250, 70),
            ),
            child: Text(
              'Réserver maintenant',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      userName: '',
      isDarkMode: isDarkMode,
      toggleDarkMode: () => setState(() => isDarkMode = !isDarkMode),
      currentIndex: _currentIndex,
      onNavTap: _onNavTap,
      child: _getCurrentPage(),
    );
  }
}