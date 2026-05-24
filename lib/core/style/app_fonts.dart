import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle logo = GoogleFonts.montserrat(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final TextStyle title = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold, // ou FontWeight.w700
    color: AppColors.textTitle,
  );

  static final TextStyle titleId = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold, // ou FontWeight.w700
    color: AppColors.secondary,
  );

  static final TextStyle titleIdCandidato = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold, // ou FontWeight.w700
    color: AppColors.primary,
  );

  static final TextStyle subtitle = GoogleFonts.montserrat(
    fontSize: 16,
    color: AppColors.textBody,
  );

  static final TextStyle tutorialArraste = GoogleFonts.montserrat(
    fontSize: 12,
    color: AppColors.textBody,
  );

  static final TextStyle inputLabel = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600, // Semi-bold para rótulos fica excelente
    color: AppColors.textTitle,
  );

  static final TextStyle buttonText = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}