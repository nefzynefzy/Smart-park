import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/core/constants.dart';
import 'ParkingSelectionPage.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();

  int selectedDayIndex = DateTime.now().weekday % 7;
  int? selectedHour;
  int selectedCarIndex = 0;

  double? totalAmount;
  String? paymentRedirectUrl;
  String? errorMessage;
  bool isLoading = false;

  final List<String> days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  final List<int> hours = List.generate(16, (i) => 6 + i); // 6 to 21
  final List<String> carImages = ['assets/images/car1.png', 'assets/images/car2.png'];

  String get startTime => '${hours[selectedHour!]}:00';
  String get endTime => '${hours[selectedHour!] + 1}:00';

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate() || selectedHour == null) {
      setState(() => errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final reservation = {
      "userId": 1,
      "parkingPlaceId": 1,
      "matricule": _matriculeController.text.trim(),
      "startTime": startTime,
      "endTime": endTime,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/createReservation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reservation),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalAmount = data['amount'];
          paymentRedirectUrl = data['redirect_url'];
        });
        _showPaymentDialog();
      } else {
        setState(() => errorMessage = 'Erreur: ${response.body}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Erreur: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Paiement requis', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Montant : ${totalAmount?.toStringAsFixed(2)} DT\nMerci de finaliser votre paiement.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (paymentRedirectUrl != null) _launchURL(paymentRedirectUrl!);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Payer maintenant', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFA726),
        centerTitle: true,
        title: const Text('Réservation de Parking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (errorMessage != null) _buildErrorMessage(errorMessage!),
                    const Text("Sélectionner une date", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildDaySelector(),
                    const SizedBox(height: 20),
                    const Text("Choisir une heure", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTimeSelector(),
                    const SizedBox(height: 20),
                    const Text("Sélectionner votre véhicule", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCarSelector(),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _matriculeController,
                      label: 'Matricule du véhicule',
                      icon: Icons.directions_car,
                      validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 30),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA726)),
                              label: const Text("Retour", style: TextStyle(color: Color(0xFFFFA726))),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFFFA726)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submitReservation,
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              label: const Text("Suivant", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA726),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(days[i]),
            selected: selectedDayIndex == i,
            selectedColor: const Color(0xFFFFA726),
            backgroundColor: Colors.grey[200],
            onSelected: (_) => setState(() => selectedDayIndex = i),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hours.map((hour) {
        final selected = selectedHour == hours.indexOf(hour);
        return GestureDetector(
          onTap: () => setState(() => selectedHour = hours.indexOf(hour)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFA726) : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCarSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: carImages.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => setState(() => selectedCarIndex = index),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedCarIndex == index ? const Color(0xFFFFA726) : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: Image.asset(carImages[index], width: 70),
          ),
        ),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: const Color(0xFFFFA726)),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
