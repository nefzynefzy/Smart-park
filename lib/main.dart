import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/abonnement_screen.dart';
import 'screens/profil_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('jwt_token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      // Définir la route initiale en fonction de l'état de connexion
      initialRoute: isLoggedIn ? '/home_screen' : '/login_screen',
      routes: {
        '/login_screen': (context) => const LoginScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/reservation_screen': (context) => const ReservationScreen(),
        '/abonnement_screen': (context) => const AbonnementScreen(),
        '/profil_screen': (context) =>  UserProfilePage(),
      },
    );
  }
}
