import 'package:flutter/material.dart';

class AppColors {
  // Couleurs Veepee
  static const Color primary = Color(0xFFFF006B); // Rose Veepee principal
  static const Color primaryLight = Color(0xFFFF3383); // Rose plus clair
  static const Color primaryDark = Color(0xFFE6005F); // Rose plus foncé
  static const Color secondary = Color(0xFFFF4081); // Rose secondaire
  static const Color accent = Color(0xFFFF80AB); // Rose accent

  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surface = Colors.white;

  // Couleurs de texte Veepee
  static const Color textPrimary = Color(0xFF2D2D2D); // Gris foncé principal
  static const Color textSecondary = Color(0xFF666666); // Gris moyen
  static const Color textLight = Color(0xFF999999); // Gris clair

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Couleurs condition produits
  static const Color conditionExcellent = Color(0xFF4CAF50);
  static const Color conditionGood = Color(0xFF8BC34A);
  static const Color conditionFair = Color(0xFFFF9800);
  static const Color conditionPoor = Color(0xFFFF5722);

  // Couleurs de bordure
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Couleurs spécifiques à l'app
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE1E8ED);
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);
  static const Color favorite = Color(0xFFFF006B); // Rose Veepee pour favoris
  static const Color price = Color(0xFFFF006B); // Rose Veepee pour les prix

  // Gradient Veepee
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight], // #FF006B → #FF3383
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient header
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, primaryLight], // #FF006B → #FF3383
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Couleurs supplémentaires pour UI
  static const Color searchBackground = Colors.white;
  static const Color searchBorder = Color(0xFFF0F0F0);
  static const Color inactive = Color(0xFF666666);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
} 