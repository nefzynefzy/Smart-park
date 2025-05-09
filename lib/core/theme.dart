import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: AppColors.whiteColor,
    elevation: 0,
  ),
  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      color: AppColors.subtitleColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondaryColor,
      foregroundColor: AppColors.textColor,
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.grayColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    labelStyle: GoogleFonts.poppins(color: AppColors.subtitleColor),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.whiteColor,
    selectedItemColor: AppColors.secondaryColor,
    unselectedItemColor: AppColors.subtitleColor,
    selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
  ),
  useMaterial3: true,
);

final darkTheme = ThemeData.dark().copyWith(
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.darkBackgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryDarkColor,
    foregroundColor: AppColors.whiteColor,
    elevation: 0,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.whiteColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      color: AppColors.accentLightColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondaryColor,
      foregroundColor: AppColors.textColor,
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.primaryDarkColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    labelStyle: GoogleFonts.poppins(color: AppColors.accentLightColor),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkBackgroundColor,
    selectedItemColor: AppColors.secondaryColor,
    unselectedItemColor: AppColors.accentLightColor,
    selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
  ),
  useMaterial3: true,
);