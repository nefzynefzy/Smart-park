import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int currentStep = 1;
  String billingType = 'monthly';
  int? selectedPlan;
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> plans = [];
  bool isLoading = true;
  String? errorMessage;
  String? paymentMethod = 'carte'; // Default to 'carte'
  String? cardName;
  String? cardNumber;
  String? expiryDate;
  String? cvv;
  String? userId;
  bool isPaymentProcessing = false;
  String? sessionId;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchVehicles();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/profile'),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiZWphb3VpbWFyaWVtMTdAZ21haWwuY29tIiwiaWF0IjoxNzQ2NzUwNjk2LCJleHAiOjE3NDY4MzcwOTZ9.FKMuBSC6thdZYIamMG7lLvRZhKvDZmomaCNMiPeuTRa-WGNsVIyXGEjbnlzsb2wAAX7K8o4E9_W7mkVOC6CTHg',
        },
      );

      print('Fetch user profile response status: ${response.statusCode}');
      print('Fetch user profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userId = data['id'].toString();
          fetchPlans();
        });
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching user profile: $e';
      });
    }
  }

  Future<void> fetchVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/vehicles?userId=$userId'),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiZWphb3VpbWFyaWVtMTdAZ21haWwuY29tIiwiaWF0IjoxNzQ2NzUwNjk2LCJexPAiOjE3NDY4MzcwOTZ9.FKMuBSC6thdZYIamMG7lLvRZhKvDZmomaCNMiPeuTRa-WGNsVIyXGEjbnlzsb2wAAX7K8o4E9_W7mkVOC6CTHg',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          vehicles = data.map((vehicle) => {
            'id': vehicle['id'],
            'name': vehicle['name'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        errorMessage = 'Error loading vehicles: $e';
      });
    }
  }

  Future<void> fetchPlans() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/subscription-plans'),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiZWphb3VpbWFyaWVtMTdAZ21haWwuY29tIiwiaWF0IjoxNzQ2NzUwNjk2LCJexPAiOjE3NDY4MzcwOTZ9.FKMuBSC6thdZYIamMG7lLvRZhKvDZmomaCNMiPeuTRa-WGNsVIyXGEjbnlzsb2wAAX7K8o4E9_W7mkVOC6CTHg',
        },
      );

      print('Fetch plans response status: ${response.statusCode}');
      print('Fetch plans response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          setState(() {
            plans = data.map((plan) {
              final double monthlyPrice = (plan['monthlyPrice'] as num?)?.toDouble() ?? 0.0;
              final double annualPrice = monthlyPrice * 12 * 0.8;

              final int parkingDurationLimit = (plan['parkingDurationLimit'] as num?)?.toInt() ?? 0;
              final int advanceReservationDays = (plan['advanceReservationDays'] as num?)?.toInt() ?? 0;
              final bool hasPremiumSpots = plan['hasPremiumSpots'] == true || plan['hasPremiumSpots'] == 1;
              final bool hasValetService = plan['hasValetService'] == true || plan['hasValetService'] == 1;

              final List<String> features = [
                'Accès à tous les parkings',
                parkingDurationLimit > 0
                    ? '$parkingDurationLimit heures de stationnement par jour'
                    : 'Stationnement illimité',
                'Réservation $advanceReservationDays jour${advanceReservationDays != 1 ? 's' : ''} à l\'avance',
                if (hasPremiumSpots) 'Accès aux places premium',
                if (hasValetService) 'Service de voiturier inclus',
              ];

              final List<String> excludedFeatures = [];
              if (!hasPremiumSpots) excludedFeatures.add('Places premium');
              if (!hasValetService) excludedFeatures.add('Service de voiturier');

              return {
                'id': (plan['id'] as num?)?.toInt() ?? 0,
                'name': plan['type'] as String? ?? 'Unknown Plan',
                'monthlyPrice': monthlyPrice,
                'annualPrice': annualPrice,
                'features': features,
                'excludedFeatures': excludedFeatures,
                'isPopular': plan['isPopular'] as bool? ?? false,
              };
            }).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format: Expected a JSON array, got ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load plans: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading plans: $e';
      });
    }
  }

  void nextStep() {
    setState(() {
      if (currentStep < 2) currentStep++;
    });
  }

  void selectPlan(int planId) {
    setState(() {
      selectedPlan = planId;
    });
  }

  void toggleBillingType() {
    setState(() {
      billingType = billingType == 'monthly' ? 'annual' : 'monthly';
    });
  }

  void selectPaymentMethod(String method) {
    setState(() {
      paymentMethod = method;
      cardName = null;
      cardNumber = null;
      expiryDate = null;
      cvv = null;
    });
  }

  Future<void> initiatePayment() async {
    if (selectedPlan == null || paymentMethod == null || userId == null ||
        (paymentMethod == 'carte' && (cardName == null || cardNumber == null || expiryDate == null || cvv == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.')),
      );
      return;
    }

    setState(() {
      isPaymentProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiZWphb3VpbWFyaWVtMTdAZ21haWwuY29tIiwiaWF0IjoxNzQ6NzUwNjk2LCJexPAiOjE3NDY4MzcwOTZ9.FKMuBSC6thdZYIamMG7lLvRZhKvDZmomaCNMiPeuTRa-WGNsVIyXGEjbnlzsb2wAAX7K8o4E9_W7mkVOC6CTHg',
        },
        body: jsonEncode({
          'userId': userId,
          'subscriptionType': plans.firstWhere((plan) => plan['id'] == selectedPlan)['name'],
          'billingCycle': billingType,
        }),
      );

      print('Subscribe response status: ${response.statusCode}');
      print('Subscribe response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final redirectUrl = data['redirect_url'] as String;
        sessionId = data['session_id'] as String;

        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                print('WebView navigating to: $url');
                if (url.contains('/api/payment/callback')) {
                  checkPaymentStatus();
                  Navigator.of(context).pop();
                }
              },
              onWebResourceError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors du chargement du paiement: ${error.description}')),
                );
                setState(() {
                  isPaymentProcessing = false;
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(redirectUrl));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: SizedBox(
              height: 400,
              child: WebViewWidget(controller: _webViewController!),
            ),
          ),
        );
      } else {
        throw Exception('Failed to initiate payment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error initiating payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du paiement. Veuillez réessayer.')),
      );
      setState(() {
        isPaymentProcessing = false;
      });
    }
  }

  Future<void> checkPaymentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8082/parking/api/subscriptions/active?userId=$userId'),
        headers: {
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJiZWphb3VpbWFyaWVtMTdAZ21haWwuY29tIiwiaWF0IjoxNzQ6NzUwNjk2LCJexPAiOjE3NDY4MzcwOTZ9.FKMuBSC6thdZYIamMG7lLvRZhKvDZmomaCNMiPeuTRa-WGNsVIyXGEjbnlzsb2wAAX7K8o4E9_W7mkVOC6CTHg',
        },
      );

      print('Check payment status response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);
        if (statusData['status'] == 'ACTIVE') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement validé avec succès!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec du paiement. Veuillez réessayer.')),
          );
        }
      } else {
        throw Exception('Failed to check payment status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking payment status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la vérification du paiement.')),
      );
    } finally {
      setState(() {
        isPaymentProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFFE57373),
                ).copyWith(fontFamilyFallback: ['Roboto']),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ).copyWith(fontFamilyFallback: ['Roboto']),
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: currentStep >= 1
                                    ? const Color(0xFF6A1B9A)
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                              color: currentStep >= 1
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: currentStep > 1
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                '1',
                                style: TextStyle(
                                  color: currentStep >= 1
                                      ? Colors.white
                                      : const Color(0xFFD1D5DB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choix du forfait',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: currentStep >= 1
                                  ? const Color(0xFF374151)
                                  : const Color(0xFF9CA3AF),
                            ).copyWith(fontFamilyFallback: ['Roboto']),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                height: 2,
                                color: const Color(0xFFE5E7EB),
                              ),
                              Container(
                                height: 2,
                                width: currentStep >= 2
                                    ? MediaQuery.of(context).size.width * 0.5
                                    : 0,
                                color: const Color(0xFF6A1B9A),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: currentStep >= 2
                                    ? const Color(0xFF6A1B9A)
                                    : const Color(0xFFD1D5DB),
                                width: 2,
                              ),
                              color: currentStep >= 2
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: currentStep >= 2
                                      ? Colors.white
                                      : const Color(0xFFD1D5DB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Paiement',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: currentStep >= 2
                                  ? const Color(0xFF374151)
                                  : const Color(0xFF9CA3AF),
                            ).copyWith(fontFamilyFallback: ['Roboto']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (currentStep == 1) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisissez votre forfait',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E0D2B),
                          ).copyWith(fontFamilyFallback: ['Roboto']),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mensuel',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ).copyWith(fontFamilyFallback: ['Roboto']),
                            ),
                            const SizedBox(width: 4),
                            Switch(
                              value: billingType == 'annual',
                              onChanged: (value) => toggleBillingType(),
                              activeColor: const Color(0xFF6A1B9A),
                              inactiveTrackColor: const Color(0xFFEEEEEE),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Annuel',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ).copyWith(fontFamilyFallback: ['Roboto']),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F3D6),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '-20%',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF806F1F),
                                ).copyWith(fontFamilyFallback: ['Roboto']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plans.map((plan) {
                        if (plan['name'] == null || plan['monthlyPrice'] == null) {
                          return const SizedBox.shrink();
                        }
                        final isSelected = selectedPlan == plan['id'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => selectPlan(plan['id'] as int),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6A1B9A)
                                      : const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Text(
                                        plan['name'] as String,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E0D2B),
                                        ).copyWith(fontFamilyFallback: ['Roboto']),
                                      ),
                                      if (plan['isPopular'] as bool)
                                        Positioned(
                                          top: -30,
                                          right: -16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD4AF37),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'POPULAIRE',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1E0D2B),
                                              ).copyWith(fontFamilyFallback: ['Roboto']),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    billingType == 'monthly'
                                        ? '${(plan['monthlyPrice'] as double).toStringAsFixed(0)} TND /mois'
                                        : '${(plan['annualPrice'] as double).toStringAsFixed(0)} TND /an',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E0D2B),
                                    ).copyWith(fontFamilyFallback: ['Roboto']),
                                  ),
                                  const SizedBox(height: 16),
                                  ...(plan['features'] as List<String>).map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          color: Color(0xFF6A1B9A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF757575),
                                            ).copyWith(fontFamilyFallback: ['Roboto']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  ...(plan['excludedFeatures'] as List<String>?)?.map((excluded) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.close,
                                          color: Color(0xFFEF4444),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            excluded,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF9CA3AF),
                                            ).copyWith(fontFamilyFallback: ['Roboto']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )) ?? [],
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => selectPlan(plan['id'] as int),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? const Color(0xFF6A1B9A)
                                          : Colors.white,
                                      foregroundColor: isSelected
                                          ? Colors.white
                                          : const Color(0xFF6A1B9A),
                                      side: const BorderSide(
                                        color: Color(0xFF6A1B9A),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(double.infinity, 40),
                                    ),
                                    child: Text(
                                      isSelected ? 'Sélectionné' : 'Choisir ce forfait',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ).copyWith(fontFamilyFallback: ['Roboto']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: vehicles.isNotEmpty && selectedPlan != null
                          ? () {
                        nextStep();
                        print('Navigating to step $currentStep');
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continuer',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ).copyWith(fontFamilyFallback: ['Roboto']),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (vehicles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Veuillez ajouter un véhicule dans votre profil avant de continuer.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFE57373),
                        ).copyWith(fontFamilyFallback: ['Roboto']),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
                if (currentStep == 2) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E0D2B),
                          ).copyWith(fontFamilyFallback: ['Roboto']),
                        ),
                        const SizedBox(height: 16),
                        if (selectedPlan != null)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Forfait sélectionné: ${plans.firstWhere((plan) => plan['id'] == selectedPlan)['name']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E0D2B),
                                  ).copyWith(fontFamilyFallback: ['Roboto']),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Montant: ${billingType == 'monthly' ? (plans.firstWhere((plan) => plan['id'] == selectedPlan)['monthlyPrice'] as double).toStringAsFixed(0) : (plans.firstWhere((plan) => plan['id'] == selectedPlan)['annualPrice'] as double).toStringAsFixed(0)} TND /${billingType == 'monthly' ? 'mois' : 'an'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E0D2B),
                                  ).copyWith(fontFamilyFallback: ['Roboto']),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Méthode de paiement',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E0D2B),
                                ).copyWith(fontFamilyFallback: ['Roboto']),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => selectPaymentMethod('carte'),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: paymentMethod == 'carte'
                                            ? const Color(0xFFF3E5FF)
                                            : Colors.white,
                                        border: Border.all(
                                          color: paymentMethod == 'carte'
                                              ? const Color(0xFF6A1B9A)
                                              : const Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: paymentMethod == 'carte'
                                                ? const Color(0xFF6A1B9A)
                                                : const Color(0xFF757575),
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Carte bancaire',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: paymentMethod == 'carte'
                                                  ? const Color(0xFF6A1B9A)
                                                  : const Color(0xFF757575),
                                            ).copyWith(fontFamilyFallback: ['Roboto']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => selectPaymentMethod('poste'),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: paymentMethod == 'poste'
                                            ? const Color(0xFFF3E5FF)
                                            : Colors.white,
                                        border: Border.all(
                                          color: paymentMethod == 'poste'
                                              ? const Color(0xFF6A1B9A)
                                              : const Color(0xFFE5E7EB),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.local_post_office,
                                            color: paymentMethod == 'poste'
                                                ? const Color(0xFF6A1B9A)
                                                : const Color(0xFF757575),
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Carte postale',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: paymentMethod == 'poste'
                                                  ? const Color(0xFF6A1B9A)
                                                  : const Color(0xFF757575),
                                            ).copyWith(fontFamilyFallback: ['Roboto']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                onChanged: (value) => cardNumber = value,
                                decoration: InputDecoration(
                                  labelText: 'Numéro de carte',
                                  labelStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF757575),
                                  ).copyWith(fontFamilyFallback: ['Roboto']),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.credit_card,
                                    color: Color(0xFF757575),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) => expiryDate = value,
                                      decoration: InputDecoration(
                                        labelText: 'MM/AA',
                                        labelStyle: GoogleFonts.poppins(
                                          color: const Color(0xFF757575),
                                        ).copyWith(fontFamilyFallback: ['Roboto']),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) => cvv = value,
                                      decoration: InputDecoration(
                                        labelText: 'CVV',
                                        labelStyle: GoogleFonts.poppins(
                                          color: const Color(0xFF757575),
                                        ).copyWith(fontFamilyFallback: ['Roboto']),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.help_outline,
                                            color: Color(0xFF757575),
                                          ),
                                          onPressed: () {
                                            // Show tooltip or dialog for CVV info
                                          },
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                onChanged: (value) => cardName = value,
                                decoration: InputDecoration(
                                  labelText: 'Nom sur la carte',
                                  labelStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF757575),
                                  ).copyWith(fontFamilyFallback: ['Roboto']),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: true,
                                    onChanged: (value) {},
                                    activeColor: const Color(0xFF6A1B9A),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Sauvegarder cette méthode pour mes prochains paiements',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF757575),
                                      ).copyWith(fontFamilyFallback: ['Roboto']),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (currentStep > 1) currentStep--;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF6A1B9A),
                                      side: const BorderSide(color: Color(0xFF6A1B9A)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.arrow_back),
                                        SizedBox(width: 8),
                                        Text('Retour'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: isPaymentProcessing ? null : initiatePayment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A1B9A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      minimumSize: const Size(150, 48),
                                    ),
                                    child: isPaymentProcessing
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Row(
                                      children: const [
                                        Text('Confirmer et payer'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward),
                                      ],
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}