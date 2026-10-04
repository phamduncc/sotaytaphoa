import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette – deep blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryContainer = Color(0xFFD6E4FF);

  // Secondary – warm amber
  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryContainer = Color(0xFFFFE0B2);

  // Semantic colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFC8E6C9);

  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorContainer = Color(0xFFFFCDD2);

  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFB300);
  static const Color warningContainer = Color(0xFFFFF9C4);

  static const Color info = Color(0xFF0277BD);
  static const Color infoContainer = Color(0xFFB3E5FC);

  // Income / Expense
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFC62828);

  // Light theme surface colors
  static const Color backgroundLight = Color(0xFFF4F6FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0E7EF);
  static const Color borderLight = Color(0xFFCDD5E0);

  // Dark theme surface colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF475569);

  // Text – light theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textHintLight = Color(0xFF94A3B8);

  // Text – dark theme
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);

  // Dashboard card gradients
  static const LinearGradient gradientRevenue = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientProfit = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientInvoice = LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradientWarning = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
