import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2962FF),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2962FF),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(),
  useMaterial3: true,
);

final darkTheme = ThemeData.dark().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
);
