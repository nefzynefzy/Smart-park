import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanVehiclePage extends StatefulWidget {
  const ScanVehiclePage({Key? key}) : super(key: key);

  @override
  State<ScanVehiclePage> createState() => _ScanVehiclePageState();
}

class _ScanVehiclePageState extends State<ScanVehiclePage> {
  String? qrText;
  String reservationNumber = "RES-1746731969746"; // Example reservation number

  @override
  void dispose() {
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        qrText = barcodes.first.rawValue;
        if (qrText == reservationNumber) {
          _showConfirmationDialog();
        } else {
          _showErrorDialog("QR code invalide. Veuillez réessayer.");
        }
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Réservation validée avec succès!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le QR Code')),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(qrText ?? 'Scannez un code QR'),
            ),
          ),
        ],
      ),
    );
  }
}