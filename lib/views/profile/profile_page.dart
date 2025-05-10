import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_parking/core/constants.dart';
import 'package:smart_parking/views/auth/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Add this for image picking
import 'dart:io'; // For File handling

import '../../widgets/primary_button.dart';
import '../Settings/help_support_page.dart';
import '../Settings/language_preferences_page.dart';
import '../Settings/notification_settings_page.dart';
import '../Settings/privacy_settings_page.dart';
import '../reservation/reservation_details.dart';
import '../subscription/subscription_history_page.dart';
import '../subscription/subscription_page.dart';
import '../vehicle/vehicle_details_page.dart';
import '../vehicle/vehicle_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? errorMessage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // State for collapsible sections
  bool _isReservationsExpanded = false;
  bool _isVehiclesExpanded = false;
  bool _isSubscriptionExpanded = false;
  bool _isProfileEditExpanded = false;
  bool _isPasswordEditExpanded = false;
  bool _isAddVehicleExpanded = false;

  // Controllers for profile editing
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers for password changing
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool useEmailVerification = true;
  bool _isVerificationCodeSent = false;

  // Controllers for vehicle addition
  final _matriculeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  File? _matriculeImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<String?> _getToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return token;
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la récupération du token: $e';
      });
      return null;
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String? token = await _getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de récupération du profil';
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
        throw Exception('Erreur de récupération du profil');
      });

      print('Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userProfile = data;
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await _storage.delete(key: 'auth_token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        setState(() {
          errorMessage = 'Erreur de récupération du profil: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de récupération du profil: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8082/parking/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isProfileEditExpanded = false;
          userProfile = json.decode(response.body);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
        setState(() {
          _isVerificationCodeSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code de vérification envoyé via ${useEmailVerification ? 'email' : 'SMS'}')),
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

  Future<void> _changePassword() async {
    if (_verificationCodeController.text.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez entrer le code de vérification';
      });
      return;
    }

    final token = await _getToken();
    if (token == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

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
          'verificationCode': _verificationCodeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isPasswordEditExpanded = false;
          _isVerificationCodeSent = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _verificationCodeController.clear();
        });
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'remembered_email');
      await _storage.delete(key: 'remembered_password');
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la déconnexion: $e';
      });
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<String> _processMatriculeImage(File image) async {
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

  Future<void> _pickMatriculeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _matriculeImage = File(pickedFile.path);
      });
      try {
        final matricule = await _processMatriculeImage(File(pickedFile.path));
        setState(() {
          _matriculeController.text = matricule;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Erreur lors du traitement de l\'image: $e';
        });
      }
    }
  }

  Future<void> _submitVehicle() async {
    if (_matriculeController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _colorController.text.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final vehicleData = {
      'matricule': _matriculeController.text.trim(),
      'vehicleType': 'car',
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'color': _colorController.text.trim(),
    };

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8082/parking/api/vehicle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 201) {
        setState(() {
          _isAddVehicleExpanded = false;
          _matriculeController.clear();
          _brandController.clear();
          _modelController.clear();
          _colorController.clear();
          _matriculeImage = null;
        });
        await _fetchUserProfile(); // Refresh the profile to update the vehicle list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Véhicule ajouté avec succès')),
        );
      } else {
        setState(() {
          errorMessage = 'Erreur: ${response.body}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Mon Profil',
          style: GoogleFonts.poppins(
            color: AppColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.whiteColor),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
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
        child: SingleChildScrollView(
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
              // Profile Header
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLightColor,
                        child: Text(
                          '${(userProfile?['firstName'] ?? '').toString().isNotEmpty ? (userProfile?['firstName'] as String)[0] : ''}'
                              '${(userProfile?['lastName'] ?? '').toString().isNotEmpty ? (userProfile?['lastName'] as String)[0] : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${userProfile?['firstName'] ?? ''} ${userProfile?['lastName'] ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile?['email'] ?? 'email@example.com',
                        style: GoogleFonts.poppins(
                          color: AppColors.subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Téléphone: ${userProfile?['phone'] ?? 'Non défini'}',
                        style: GoogleFonts.poppins(
                          color: AppColors.subtitleColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Modifier le Profil',
                        icon: Icons.edit,
                        onPressed: () {
                          setState(() {
                            _isProfileEditExpanded = !_isProfileEditExpanded;
                          });
                        },
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isProfileEditExpanded)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.grayColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.grayColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.grayColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.grayColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                          label: 'Enregistrer',
                          onPressed: _updateProfile,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Quick Actions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock, color: AppColors.primaryColor),
                  ),
                  title: Text(
                    'Changer le Mot de Passe',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Mettre à jour la sécurité du compte',
                    style: GoogleFonts.poppins(
                      color: AppColors.subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                  onTap: () {
                    setState(() {
                      _isPasswordEditExpanded = !_isPasswordEditExpanded;
                    });
                  },
                ),
              ),
              if (_isPasswordEditExpanded)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(top: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
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
                                title: Text(
                                  'Vérification par email',
                                  style: GoogleFonts.poppins(),
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
                                title: Text(
                                  'Vérification par SMS',
                                  style: GoogleFonts.poppins(),
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
                        if (_isVerificationCodeSent) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _verificationCodeController,
                            decoration: InputDecoration(
                              labelText: 'Code de vérification',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.grayColor,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        isLoading
                            ? const CircularProgressIndicator()
                            : PrimaryButton(
                          label: _isVerificationCodeSent ? 'Soumettre' : 'Demander le code',
                          onPressed: _isVerificationCodeSent ? _changePassword : _requestPasswordReset,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Reservations Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _isReservationsExpanded = !_isReservationsExpanded;
                    });
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event, color: AppColors.successColor),
                  ),
                  title: Text(
                    'Mes Réservations',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  subtitle: Text(
                    'Voir et gérer mes réservations',
                    style: GoogleFonts.poppins(
                      color: AppColors.subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    _isReservationsExpanded ? Icons.expand_less : Icons.chevron_right,
                    color: AppColors.subtitleColor,
                  ),
                ),
              ),
              if (_isReservationsExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: PrimaryButton(
                    label: 'Voir mes réservations',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReservationDetailsPage()),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Vehicles Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            _isVehiclesExpanded = !_isVehiclesExpanded;
                          });
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(AppIcons.vehicle, color: AppColors.primaryColor),
                        ),
                        title: Text(
                          'Mes Véhicules',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: Icon(
                          _isVehiclesExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.subtitleColor,
                        ),
                      ),
                      if (_isVehiclesExpanded) ...[
                        const Divider(),
                        if (userProfile?['vehicles'] != null && (userProfile?['vehicles'] as List).isNotEmpty)
                          ...List.generate(
                            (userProfile?['vehicles'] as List).length,
                                (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLightColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(AppIcons.vehicle, color: AppColors.primaryColor),
                                ),
                                title: Text(
                                  '${(userProfile?['vehicles'][index]['brand'] ?? 'N/A')} ${(userProfile?['vehicles'][index]['model'] ?? 'N/A')}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Matricule: ${(userProfile?['vehicles'][index]['matricule'] ?? 'N/A')} • Couleur: ${(userProfile?['vehicles'][index]['color'] ?? 'N/A')}',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VehicleDetailsPage(
                                        vehicle: userProfile?['vehicles'][index],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              const Icon(AppIcons.vehicle, size: 48, color: AppColors.subtitleColor),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun véhicule',
                                style: GoogleFonts.poppins(
                                  color: AppColors.subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isAddVehicleExpanded = !_isAddVehicleExpanded;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 16, color: AppColors.primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Ajouter un Véhicule',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isAddVehicleExpanded) ...[
                          const Divider(),
                          TextField(
                            controller: _matriculeController,
                            decoration: InputDecoration(
                              labelText: 'Matricule',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.grayColor,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: _pickMatriculeImage,
                              ),
                            ),
                          ),
                          if (_matriculeImage != null) ...[
                            const SizedBox(height: 16),
                            Image.file(
                              _matriculeImage!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: _brandController,
                            decoration: InputDecoration(
                              labelText: 'Marque',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.grayColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _modelController,
                            decoration: InputDecoration(
                              labelText: 'Modèle',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.grayColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _colorController,
                            decoration: InputDecoration(
                              labelText: 'Couleur',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.grayColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          isLoading
                              ? const CircularProgressIndicator()
                              : PrimaryButton(
                            label: 'Ajouter',
                            onPressed: _submitVehicle,
                            isFullWidth: true,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subscription Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            _isSubscriptionExpanded = !_isSubscriptionExpanded;
                          });
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.subscriptions, color: AppColors.secondaryColor),
                        ),
                        title: Text(
                          'Mon Abonnement',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: Icon(
                          _isSubscriptionExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.subtitleColor,
                        ),
                      ),
                      if (_isSubscriptionExpanded) ...[
                        const Divider(),
                        ListTile(
                          title: Text(
                            'Plan Premium', // Placeholder; update with actual plan if available
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Valide jusqu\'au ${userProfile?['subscription']?['subscriptionEndDate'] ?? 'Non défini'}',
                            style: GoogleFonts.poppins(
                              color: AppColors.subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SubscriptionPage()),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Gérer',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, color: AppColors.primaryColor, size: 16),
                              ],
                            ),
                          ),
                          tileColor: AppColors.grayColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SubscriptionHistoryPage()),
                              );
                            },
                            icon: const Icon(Icons.history, color: AppColors.subtitleColor),
                            label: Text(
                              'Voir l\'historique des abonnements',
                              style: GoogleFonts.poppins(
                                color: AppColors.subtitleColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Logout Button
              PrimaryButton(
                label: 'Déconnexion',
                icon: Icons.logout,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}