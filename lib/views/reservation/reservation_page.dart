import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _verificationCodeController = TextEditingController();

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
  bool isSubscribed = false;
  XFile? _matriculeImage;
  String? reservationId;
  String? paymentVerificationCode;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    if (userVehicles.isNotEmpty) selectedVehicleIndex = 0;
    _fetchUserVehicles();
    _checkSubscriptionStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _checkSubscriptionStatus() async {
    print('Checking subscription status...');
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

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        errorMessage = 'Aucune connexion Internet. Veuillez vérifier votre connexion.';
      });
      return false;
    }
    return true;
  }

  Future<void> _fetchUserVehicles() async {
    print('Fetching user vehicles...');
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur: Token d\'authentification manquant.';
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final userProfile = json.decode(response.body);
        setState(() {
          userVehicles = List<Map<String, dynamic>>.from(userProfile['vehicles'] ?? [])
              .map((v) => {
            'id': v['id'] ?? 'UNKNOWN',
            'name': '${v['brand']} ${v['model']}',
          })
              .toList();
          showAddVehicleForm = userVehicles.isEmpty;
          if (userVehicles.isNotEmpty && selectedVehicleIndex == null) {
            selectedVehicleIndex = 0;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors de la récupération des véhicules: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur réseau: Impossible de récupérer les véhicules.';
        isLoading = false;
      });
    }
  }

  Future<void> _addVehicle() async {
    print('Adding vehicle...');
    if (!_formKey.currentState!.validate() || _matriculeImage == null) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs et ajouter une image.';
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final isConnected = await _checkConnectivity();
    if (!isConnected) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final String matricule = await _processMatriculeImage(_matriculeImage!);
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
        'matricule': matricule,
        'vehicleType': 'car',
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'matriculeImageUrl': '',
      };
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
          _matriculeImage = null;
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
        errorMessage = 'Erreur: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _selectParkingSpot() async {
    print('Selecting parking spot...');
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
          matricule: selectedVehicleIndex != null && userVehicles[selectedVehicleIndex!]['id'] != null
              ? userVehicles[selectedVehicleIndex!]['id'].toString()
              : 'N/A',
          userId: 1,
        ),
      ),
    );
    if (result != null) {
      if (result is String) {
        setState(() {
          selectedSpotId = result;
          selectedPlace = {
            'id': result,
            'name': result,
            'type': result.contains('A') ? 'premium' : 'standard',
            'price': result.contains('A') ? 8.0 : 5.0,
            'features': result.contains('A') ? ['Couvert', 'Large'] : ['Couvert'],
          };
          totalAmount = calculateTotalCost();
        });
      } else {
        setState(() {
          errorMessage = 'Erreur: La place sélectionnée n\'est pas valide.';
        });
      }
    }
  }

  Future<void> _captureOrPickImage() async {
    print('Capturing or picking image...');
    var storageStatus = await Permission.storage.status;

    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        setState(() {
          errorMessage = 'Permission de stockage refusée.';
        });
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir depuis la galerie'),
            onTap: () async {
              Navigator.pop(context);
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              try {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _matriculeImage = image;
                    isLoading = false;
                  });
                } else {
                  setState(() {
                    isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  errorMessage = 'Erreur lors de la sélection: $e';
                  isLoading = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String> _processMatriculeImage(XFile image) async {
    print('Processing matricule image...');
    final String? token = await _getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/api/process-matricule'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send().timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['matricule'] as String;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('Erreur serveur: $errorBody (Status: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion au serveur: $e';
      });
      rethrow;
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
    print('Submitting reservation...');
    if (selectedDate == null || startTime == null || endTime == null || selectedSpotId == null || _emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }
    if (selectedVehicleIndex == null) {
      setState(() {
        errorMessage = 'Veuillez sélectionner un véhicule.';
      });
      return;
    }
    if (!isSubscribed && totalAmount! > 0) {
      if (_cardNumberController.text.isEmpty || _expiryDateController.text.isEmpty || _cvvController.text.isEmpty) {
        setState(() {
          errorMessage = 'Veuillez remplir les informations de paiement.';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de réservation: token manquant';
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

    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final reservationRequest = {
      'userId': 1,
      'parkingPlaceId': int.parse(selectedSpotId!.split('-').last),
      'matricule': selectedVehicle['id'].toString(),
      'startTime': formatter.format(startDateTime),
      'endTime': formatter.format(endDateTime),
      'vehicleType': 'Voiture',
      'paymentMethod': 'CARTE_BANCAIRE',
      'specialRequest': '',
      'email': _emailController.text.trim(),
    };
    print('Reservation request: $reservationRequest');

    for (int retry = 0; retry < 3; retry++) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8082/parking/api/createReservation'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(reservationRequest),
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          print('Timeout on attempt ${retry + 1}/3');
          throw Exception('Délai de connexion dépassé. Tentative ${retry + 1}/3.');
        });
        print('Response status: ${response.statusCode}, body: ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            reservationId = data['reservationId'] as String?;
            paymentVerificationCode = data['paymentVerificationCode'] as String?;
            totalAmount = calculateTotalCost();
          });

          if (!isSubscribed && totalAmount! > 0) {
            await _finalizePayment();
            await _sendConfirmationEmail();
            await _showReservationConfirmationDialog();
          } else {
            await _sendConfirmationEmail();
            await _showReservationConfirmationDialog();
          }
          setState(() {
            isLoading = false;
          });
          return;
        } else {
          setState(() {
            errorMessage = 'Erreur de réservation: ${response.statusCode} - ${response.body}';
          });
          if (retry == 2) throw Exception('Échec après 3 tentatives.');
        }
      } catch (e) {
        print('Exception during reservation attempt ${retry + 1}: $e');
        setState(() {
          errorMessage = 'Erreur de réservation: $e';
        });
        if (retry < 2) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
    }
  }

  Future<void> _finalizePayment() async {
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de paiement: token manquant';
      });
      return;
    }

    final paymentRequest = {
      'cardNumber': _cardNumberController.text.trim(),
      'expiryDate': _expiryDateController.text.trim(),
      'cvv': _cvvController.text.trim(),
      'amount': totalAmount,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/payment'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(paymentRequest),
      ).timeout(const Duration(seconds: 10));
      print('Payment response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final redirectUrl = data['redirect_url'] as String?;
        if (redirectUrl != null) {
          await _launchURL(redirectUrl);
        }
      } else {
        setState(() {
          errorMessage = 'Erreur de paiement: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de paiement: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _showReservationConfirmationDialog() async {
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.security, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Confirmation de la réservation',
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Un code de confirmation a été envoyé à ${_emailController.text}. Veuillez entrer le code ci-dessous.',
                style: GoogleFonts.roboto(fontSize: 14, color: subtitleColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Code de confirmation',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isLoading = false;
              });
            },
            child: Text('Annuler', style: GoogleFonts.roboto(color: errorColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _confirmReservation();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Confirmer', style: GoogleFonts.roboto(color: whiteColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReservation() async {
    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = 'Erreur de confirmation de réservation: token manquant';
        isLoading = false;
      });
      return;
    }

    final numericReservationId = int.parse(reservationId!.split('-').last);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8082/parking/api/confirmReservation'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({
        'reservationId': numericReservationId,
        'reservationConfirmationCode': _verificationCodeController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        currentStep = 3;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Erreur de confirmation de réservation: ${response.body}';
        isLoading = false;
      });
    }
  }

  Future<void> _sendConfirmationEmail() async {
    print('Sending confirmation email...');
    final String? token = await _getToken();
    if (token != null) {
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      final emailRequest = {
        'email': _emailController.text.trim(),
        'reservationId': reservationId,
        'details': {
          'reservationId': reservationId,
          'startTime': formatter.format(DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            startTime!.hour,
            startTime!.minute,
          )),
          'endTime': formatter.format(DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            endTime!.hour,
            endTime!.minute,
          )),
          'placeName': selectedPlace!['name'],
          'totalAmount': totalAmount?.toStringAsFixed(2) ?? '0.00',
          'qrCodeData': reservationId ?? 'RES-${DateTime.now().millisecondsSinceEpoch}',
        },
      };
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8082/parking/api/sendConfirmationEmail'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: json.encode(emailRequest),
        );
        if (response.statusCode == 200) {
          print('Confirmation email sent successfully');
        } else {
          setState(() {
            errorMessage = 'Erreur d\'envoi de l\'email: ${response.body}';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Erreur d\'envoi de l\'email: $e';
        });
      }
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null) {
      setState(() {
        errorMessage = 'URL de paiement manquante.';
      });
      return;
    }
    print('Launching URL: $url');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      setState(() {
        errorMessage = 'Impossible de lancer l\'URL de paiement.';
      });
    }
  }

  void _nextStep() {
    print('Proceeding to next step: $currentStep');
    if (currentStep == 1 && selectedSpotId == null) {
      setState(() {
        errorMessage = 'Veuillez sélectionner une place.';
      });
      return;
    }
    if (currentStep == 2) {
      if (!_formKey.currentState!.validate()) return;
      if (selectedDate == null || startTime == null || endTime == null || _emailController.text.isEmpty) {
        setState(() {
          errorMessage = 'Veuillez remplir tous les champs.';
        });
        return;
      }
      _submitReservation();
      return;
    }
    setState(() {
      currentStep++;
    });
  }

  void _prevStep() {
    print('Going back to previous step: $currentStep');
    setState(() {
      if (currentStep > 1) currentStep--;
    });
  }

  void _reset() {
    print('Resetting form...');
    setState(() {
      currentStep = 1;
      selectedDate = DateTime.now();
      startTime = null;
      endTime = null;
      selectedVehicleIndex = userVehicles.isNotEmpty ? 0 : null;
      selectedSpotId = null;
      selectedPlace = null;
      totalAmount = null;
      _emailController.clear();
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();
      _brandController.clear();
      _modelController.clear();
      _matriculeImage = null;
      errorMessage = null;
      reservationId = null;
      paymentVerificationCode = null;
      _verificationCodeController.clear();
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    print('Selecting time (isStart: $isStart)...');
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
          if (startTime != null) {
            final startMinutes = startTime!.hour * 60 + startTime!.minute;
            final endMinutes = endTime!.hour * 60 + endTime!.minute;
            if (endMinutes <= startMinutes) {
              errorMessage = 'L\'heure de fin doit être après l\'heure de début.';
              endTime = null;
              return;
            }
          }
        }
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
                    Text('Traitement en cours...', style: GoogleFonts.roboto(color: textColor)),
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
                              Container(width: 12, height: 12, color: successColor),
                              const SizedBox(width: 4),
                              Text('Standard (5 TND/h)', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 100, height: 12, color: secondaryColor),
                              const SizedBox(width: 4),
                              Text('Premium (8 TND/h)', style: GoogleFonts.roboto(fontSize: 12, color: textColor)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 12, height: 12, color: errorColor),
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
                            boxShadow: [BoxShadow(color: grayColor.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
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
                            _buildInputField(
                              controller: _emailController,
                              label: 'Email (pour confirmation)',
                              icon: Icons.email,
                              validator: (v) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!) ? 'Email invalide' : null,
                            ),
                            const SizedBox(height: 20),
                            if (showAddVehicleForm) ...[
                              _buildCameraCapture(),
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
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _addVehicle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        'Ajouter le véhicule',
                                        style: GoogleFonts.roboto(fontSize: 14, color: whiteColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          showAddVehicleForm = false;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: primaryColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        'Passer',
                                        style: GoogleFonts.roboto(fontSize: 14, color: primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              _buildVehicleSelector(),
                            ],
                            const SizedBox(height: 20),
                            if (!isSubscribed && totalAmount != null && totalAmount! > 0) ...[
                              Row(
                                children: [
                                  const Icon(Icons.payment, color: primaryColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Détails de paiement',
                                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _cardNumberController,
                                label: 'Numéro de carte',
                                icon: Icons.credit_card,
                                validator: (v) => v!.length != 16 ? 'Numéro invalide' : null,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _expiryDateController,
                                      label: 'Date d\'expiration (MM/YY)',
                                      icon: Icons.calendar_today,
                                      validator: (v) => !RegExp(r'^\d{2}/\d{2}$').hasMatch(v!) ? 'Format invalide' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _cvvController,
                                      label: 'CVV',
                                      icon: Icons.lock,
                                      validator: (v) => v!.length != 3 ? 'CVV invalide' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Montant: ${totalAmount?.toStringAsFixed(2)} TND',
                                style: GoogleFonts.roboto(fontSize: 14, color: subtitleColor),
                              ),
                            ],
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
                          boxShadow: [BoxShadow(color: grayColor.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
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
                              'Un email de confirmation a été envoyé à ${_emailController.text}.',
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
                                  'N° de réservation: $reservationId',
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
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: QrImageView(
                                      data: reservationId ?? 'RES-${DateTime.now().millisecondsSinceEpoch}',
                                      version: QrVersions.auto,
                                      size: 100,
                                    ),
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
                                side: BorderSide(color: errorColor),
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
                                side: BorderSide(color: primaryColor),
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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: currentStep >= step ? LinearGradient(colors: [primaryColor, secondaryColor]) : null,
            color: currentStep < step ? grayColor : null,
            border: Border.all(color: primaryColor, width: 2),
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
      height: 3,
      color: isActive ? secondaryColor : grayColor.withOpacity(0.5),
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
                      borderSide: BorderSide(color: grayColor),
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
                      borderSide: BorderSide(color: grayColor),
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
                      borderSide: BorderSide(color: grayColor),
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
                  boxShadow: [BoxShadow(color: grayColor.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
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
                border: Border.all(color: selected ? secondaryColor : grayColor, width: 2),
                boxShadow: [BoxShadow(color: grayColor.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, color: primaryColor, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    vehicle['name'] ?? 'Véhicule',
                    style: GoogleFonts.roboto(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter une image de la plaque d\'immatriculation (optionnel)',
          style: GoogleFonts.roboto(fontSize: 14, color: textColor),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _captureOrPickImage,
              icon: const Icon(Icons.photo_library, color: whiteColor),
              label: Text(
                'Choisir une image',
                style: GoogleFonts.roboto(fontSize: 14, color: whiteColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
        if (_matriculeImage != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: grayColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_matriculeImage!.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    'Erreur lors du chargement de l\'image',
                    style: GoogleFonts.roboto(color: errorColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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
          borderSide: BorderSide(color: grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
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