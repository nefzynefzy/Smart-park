import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_parking/core/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool useEmailVerification = true; // Toggle between email and SMS

  Future<void> _requestPasswordReset() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'method': useEmailVerification ? 'email' : 'sms',
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code de vérification envoyé via email')),
        );
        // Navigate to verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCodePage(
              onVerified: (code) {
                _changePassword(code);
              },
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Erreur lors de la demande: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changePassword(String verificationCode) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': _currentPasswordController.text.trim(),
          'newPassword': _newPasswordController.text.trim(),
          'verificationCode': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
        );
      } else {
        setState(() {
          errorMessage = 'Erreur lors de la mise à jour: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Changer le Mot de Passe',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6E6),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE53E3E), width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Color(0xFFE53E3E), fontFamily: 'Poppins'),
                ),
              ),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.grayColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.grayColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text(
                      'Vérification par email',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    value: true,
                    groupValue: useEmailVerification,
                    onChanged: (value) {
                      setState(() {
                        useEmailVerification = value ?? true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text(
                      'Vérification par SMS',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    value: false,
                    groupValue: useEmailVerification,
                    onChanged: (value) {
                      setState(() {
                        useEmailVerification = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _requestPasswordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.textColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Soumettre',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyCodePage extends StatefulWidget {
  final Function(String) onVerified;

  const VerifyCodePage({super.key, required this.onVerified});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codeController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        title: const Text(
          'Vérifier le Code',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6E6),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE53E3E), width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Color(0xFFE53E3E), fontFamily: 'Poppins'),
                ),
              ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Code de vérification',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.grayColor,
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                widget.onVerified(_codeController.text.trim());
                setState(() {
                  isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.textColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Vérifier',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}