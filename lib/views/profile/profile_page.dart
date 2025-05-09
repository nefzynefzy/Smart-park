import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_parking/core/constants.dart';
import 'package:smart_parking/views/auth/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'change_password_page.dart';
import 'edit_profile_page.dart';

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
        setState(() {
          userProfile = json.decode(response.body);
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
          onPressed: () => Navigator.pop(context),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfilePage()),
                          );
                        },
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Quick Actions
              Column(
                children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
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
                ],
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
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                                  );
                                },
                                child: Text(
                                  'Ajouter mon premier véhicule',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                              );
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
              const SizedBox(height: 16),
              // Settings Section
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
                      Row(
                        children: [
                          const Icon(Icons.settings, color: AppColors.subtitleColor),
                          const SizedBox(width: 8),
                          Text(
                            'Paramètres',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notifications, color: AppColors.primaryColor),
                        ),
                        title: Text(
                          'Paramètres de Notification',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.security, color: AppColors.primaryColor),
                        ),
                        title: Text(
                          'Paramètres de Confidentialité',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacySettingsPage()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.language, color: AppColors.successColor),
                        ),
                        title: Text(
                          'Préférences de Langue',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LanguagePreferencesPage()),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(AppIcons.help, color: AppColors.errorColor),
                        ),
                        title: Text(
                          'Aide et Support',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.subtitleColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                          );
                        },
                      ),
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