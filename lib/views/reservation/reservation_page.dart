import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ParkingSelectionPage.dart';

const Color primaryColor = Color(0xFF6A1B9A);
const Color secondaryColor = Color(0xFFD4AF37);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color textColor = Color(0xFF1E0D2B);
const Color subtitleColor = Color(0xFF757575);
const Color errorColor = Color(0xFFE57373);
const Color successColor = Color(0xFF81C784);
const Color whiteColor = Color(0xFFFFFFFF);
const Color grayColor = Color(0xFFEEEEEE);

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? selectedVehicleIndex;
  String? selectedSpotId;
  Map<String, dynamic>? selectedPlace;
  List<Map<String, dynamic>> userVehicles = [];
  bool showAddVehicleForm = false;
  bool isLoading = false;
  String? errorMessage;
  double? totalAmount;
  String? paymentRedirectUrl;
  bool isSubscribed = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    if (userVehicles.isNotEmpty) selectedVehicleIndex = 0; // Default to first vehicle if available
    _fetchUserVehicles();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    final String? token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8082/parking/api/user/subscription'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          setState(() {
            isSubscribed = json.decode(response.body)['isSubscribed'] ?? false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Erreur de vérification de l\'abonnement: $e';
        });
      }
    }
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

  Future<void> _fetchUserVehicles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de récupération des véhicules';
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Erreur de récupération des véhicules');
      });
      if (response.statusCode == 200) {
        final userProfile = json.decode(response.body);
        setState(() {
          userVehicles = List<Map<String, dynamic>>.from(userProfile['vehicles'] ?? []);
          showAddVehicleForm = userVehicles.isEmpty;
          if (userVehicles.isNotEmpty && selectedVehicleIndex == null) selectedVehicleIndex = 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur de récupération des véhicules: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de récupération des véhicules: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de création du véhicule';
      });
      return;
    }
    final vehicleRequest = {
      'userId': 1,
      'matricule': _matriculeController.text.trim(),
      'vehicleType': 'car',
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'color': _colorController.text.trim(),
      'matriculeImageUrl': '',
    };
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/vehicle'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(vehicleRequest),
      );
      if (response.statusCode == 201) {
        await _fetchUserVehicles();
        setState(() {
          showAddVehicleForm = false;
          selectedVehicleIndex = 0;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur de création du véhicule: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de création du véhicule: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _selectParkingSpot() async {
    if (selectedVehicleIndex == null && userVehicles.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez ajouter un véhicule avant de sélectionner une place.';
      });
      return;
    }
    final selectedVehicle = userVehicles[selectedVehicleIndex ?? 0];
    final startDateTime = DateTime(
      (selectedDate ?? DateTime.now()).year,
      (selectedDate ?? DateTime.now()).month,
      (selectedDate ?? DateTime.now()).day,
      (startTime ?? TimeOfDay.now()).hour,
      (startTime ?? TimeOfDay.now()).minute,
    );
    final endDateTime = DateTime(
      (selectedDate ?? DateTime.now()).year,
      (selectedDate ?? DateTime.now()).month,
      (selectedDate ?? DateTime.now()).day,
      (endTime ?? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1)).hour,
      (endTime ?? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1)).minute,
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingSelectionPage(
          startTime: startDateTime.toIso8601String(),
          endTime: endDateTime.toIso8601String(),
          matricule: selectedVehicle['matricule'],
          userId: 1,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        selectedSpotId = result as String;
        selectedPlace = {
          'id': result,
          'name': result,
          'type': result.contains('A') ? 'premium' : 'standard',
          'price': result.contains('A') ? 8.0 : 5.0,
          'features': result.contains('A') ? ['Couvert', 'Large'] : ['Couvert'],
        };
        totalAmount = calculateTotalCost();
      });
    }
  }

  double calculateTotalCost() {
    if (selectedPlace == null || startTime == null || endTime == null) return 0.0;
    final duration = endTime!.hour - startTime!.hour + (endTime!.minute - startTime!.minute) / 60;
    final basePrice = selectedPlace!['price'] ?? 5.0;
    double cost = duration * basePrice;
    if (isSubscribed) cost *= 0.5;
    return cost > 0 ? cost : 0.0;
  }

  Future<void> _submitReservation() async {
    if (selectedDate == null || startTime == null || endTime == null || selectedSpotId == null || selectedVehicleIndex == null) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de réservation';
      });
      return;
    }
    final selectedVehicle = userVehicles[selectedVehicleIndex!];
    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    final endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
    final reservationRequest = {
      'userId': 1,
      'parkingPlaceId': int.parse(selectedSpotId!.split('-').last),
      'matricule': selectedVehicle['matricule'],
      'startTime': startDateTime.toIso8601String(),
      'endTime': endDateTime.toIso8601String(),
      'vehicleType': 'car',
      'paymentMethod': 'online',
      'specialRequest': '',
    };
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/createReservation'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(reservationRequest),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalAmount = calculateTotalCost();
          paymentRedirectUrl = data['redirect_url'];
        });
        if (!isSubscribed && totalAmount! > 0) _showPaymentDialog();
        else {
          setState(() {
            currentStep = 3;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erreur de réservation: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de réservation: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.payment, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Procéder au paiement',
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        content: Text(
          'Montant : ${totalAmount?.toStringAsFixed(2)} TND\nVeuillez initier le paiement pour confirmer votre réservation.',
          style: GoogleFonts.roboto(fontSize: 14, color: subtitleColor),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (paymentRedirectUrl != null) _launchURL(paymentRedirectUrl!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.credit_card, size: 18, color: whiteColor),
                const SizedBox(width: 8),
                Text(
                  'Payer ${totalAmount?.toStringAsFixed(2)} TND',
                  style: GoogleFonts.roboto(color: whiteColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      setState(() {
        currentStep = 3;
      });
    } else {
      setState(() {
        errorMessage = 'Impossible de lancer l\'URL de paiement.';
      });
    }
  }

  void _nextStep() {
    if (currentStep == 1 && selectedSpotId == null) {
      setState(() {
        errorMessage = 'Veuillez sélectionner une place.';
      });
      return;
    }
    if (currentStep == 2 && !_formKey.currentState!.validate()) return;
    if (currentStep == 2 && (selectedDate == null || startTime == null || endTime == null || selectedVehicleIndex == null)) {
      setState(() {
        errorMessage = 'Veuillez sélectionner une date, une heure de début, une heure de fin et un véhicule.';
      });
      return;
    }
    setState(() {
      currentStep++;
      if (currentStep == 3) _submitReservation();
    });
  }

  void _prevStep() {
    setState(() {
      if (currentStep > 1) currentStep--;
    });
  }

  void _reset() {
    setState(() {
      currentStep = 1;
      selectedDate = DateTime.now();
      startTime = null;
      endTime = null;
      selectedVehicleIndex = userVehicles.isNotEmpty ? 0 : null;
      selectedSpotId = null;
      selectedPlace = null;
      totalAmount = null;
      paymentRedirectUrl = null;
      errorMessage = null;
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startTime = picked;
        else endTime = picked;
        totalAmount = calculateTotalCost();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_parking, color: primaryColor, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        'Réservation de parking',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Garantissez votre place en quelques étapes simples',
                    style: GoogleFonts.roboto(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepIndicator(1, 'Choix de la place'),
                  Expanded(child: _buildStepLine(currentStep >= 2)),
                  _buildStepIndicator(2, 'Informations'),
                  Expanded(child: _buildStepLine(currentStep >= 3)),
                  _buildStepIndicator(3, 'Confirmation'),
                ],
              ),
            ),
            Expanded(
              child: isLoading
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
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null) _buildErrorMessage(errorMessage!),
                    if (currentStep == 1) ...[
                      Row(
                        children: [
                          const Icon(Icons.map, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Plan du parking',
                            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 12, height: 12, color: const Color(0xFFAB77C2)),
                              const SizedBox(width: 4),
                              Text('Standard (5 TND/h)', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 12, height: 12, color: secondaryColor),
                              const SizedBox(width: 4),
                              Text('Premium (8 TND/h)', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 12, height: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Réservé', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _selectParkingSpot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          selectedSpotId != null ? 'Place sélectionnée: ${selectedPlace?['name']}' : 'Choisir une place de parking',
                          style: GoogleFonts.roboto(fontSize: 16, color: whiteColor),
                        ),
                      ),
                      if (selectedPlace != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info, color: primaryColor, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Détails de la place sélectionnée',
                                    style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.place, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Place: ${selectedPlace!['name']}', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.category, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Type: ${selectedPlace!['type']}', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Tarif: ${selectedPlace!['price']} TND/h', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Avantages: ${selectedPlace!['features'].join(', ')}', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    if (currentStep == 2) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info, color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Informations',
                                  style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDateTimePicker(),
                            const SizedBox(height: 20),
                            if (showAddVehicleForm) ...[
                              _buildInputField(
                                controller: _matriculeController,
                                label: 'Véhicule (Immatriculation)',
                                icon: Icons.directions_car,
                                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _brandController,
                                label: 'Marque',
                                icon: Icons.branding_watermark,
                                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _modelController,
                                label: 'Modèle',
                                icon: Icons.model_training,
                                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _colorController,
                                label: 'Couleur',
                                icon: Icons.color_lens,
                                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _addVehicle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  'Ajouter le véhicule',
                                  style: GoogleFonts.roboto(fontSize: 16, color: whiteColor),
                                ),
                              ),
                            ] else ...[
                              _buildVehicleSelector(),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.receipt, color: primaryColor, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Récapitulatif',
                                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.place, color: primaryColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Place: ${selectedPlace?['name'] ?? 'Aucune'}', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.category, color: primaryColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Type: ${selectedPlace?['type'] ?? '-'}', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, color: primaryColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Durée: ${startTime != null && endTime != null ? '${endTime!.hour - startTime!.hour + (endTime!.minute - startTime!.minute) / 60}h' : '0h'}',
                                        style: GoogleFonts.roboto(fontSize: 12, color: textColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, color: primaryColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Tarif horaire: ${selectedPlace?['price'] ?? 0} TND/h', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.payments, color: secondaryColor, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Total à payer: ${totalAmount?.toStringAsFixed(2) ?? 0} TND',
                                        style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (currentStep == 3) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle, color: successColor, size: 50),
                            const SizedBox(height: 16),
                            Text(
                              'Réservation confirmée!',
                              style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Votre place de parking a été réservée avec succès. Un email de confirmation vous a été envoyé.',
                              style: GoogleFonts.roboto(fontSize: 12, color: textColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.confirmation_number, color: primaryColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'N° de réservation: RES-${DateTime.now().millisecondsSinceEpoch}',
                                  style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [primaryColor, Color(0xFF3A0F5A)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.qr_code, color: whiteColor, size: 50),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Présentez ce QR code à l\'arrivée',
                                    style: GoogleFonts.roboto(fontSize: 12, color: textColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _reset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, size: 18, color: whiteColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nouvelle réservation',
                                    style: GoogleFonts.roboto(fontSize: 16, color: whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (currentStep == 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reset,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: errorColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.refresh, size: 18, color: errorColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Réinitialiser',
                                    style: GoogleFonts.roboto(fontSize: 14, color: errorColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (currentStep > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _prevStep,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back, size: 18, color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentStep == 2 ? 'Retour' : 'Modifier',
                                    style: GoogleFonts.roboto(fontSize: 14, color: primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (currentStep < 3) const SizedBox(width: 12),
                        if (currentStep < 3)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Suivant',
                                    style: GoogleFonts.roboto(fontSize: 14, color: whiteColor),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18, color: whiteColor),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentStep >= step ? primaryColor : grayColor,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: currentStep >= step ? whiteColor : textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? secondaryColor : grayColor,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2026),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de réservation',
                    labelStyle: GoogleFonts.roboto(color: subtitleColor),
                    prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: grayColor),
                    ),
                    filled: true,
                    fillColor: whiteColor,
                  ),
                  child: Text(
                    selectedDate == null ? 'Choisir une date' : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    style: GoogleFonts.roboto(color: textColor, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, true),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Heure de début',
                    labelStyle: GoogleFonts.roboto(color: subtitleColor),
                    prefixIcon: const Icon(Icons.access_time, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: grayColor),
                    ),
                    filled: true,
                    fillColor: whiteColor,
                  ),
                  child: Text(
                    startTime == null ? 'Choisir une heure' : startTime!.format(context),
                    style: GoogleFonts.roboto(color: textColor, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, false),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Heure de fin',
                    labelStyle: GoogleFonts.roboto(color: subtitleColor),
                    prefixIcon: const Icon(Icons.access_time, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: grayColor),
                    ),
                    filled: true,
                    fillColor: whiteColor,
                  ),
                  child: Text(
                    endTime == null ? 'Choisir une heure' : endTime!.format(context),
                    style: GoogleFonts.roboto(color: textColor, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: userVehicles.length + 1,
        itemBuilder: (context, index) {
          if (index == userVehicles.length) {
            return GestureDetector(
              onTap: () => setState(() => showAddVehicleForm = true),
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: primaryColor, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      'Ajouter un véhicule',
                      style: GoogleFonts.roboto(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          final vehicle = userVehicles[index];
          final selected = selectedVehicleIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedVehicleIndex = index),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? secondaryColor : grayColor,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, color: primaryColor, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    vehicle['matricule'],
                    style: GoogleFonts.roboto(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${vehicle['brand']} ${vehicle['model']}',
                    style: GoogleFonts.roboto(color: subtitleColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.roboto(color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: whiteColor,
        prefixIcon: Icon(icon, color: primaryColor),
        labelText: label,
        labelStyle: GoogleFonts.roboto(color: subtitleColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
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