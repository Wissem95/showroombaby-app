class AppConstants {
  // App Info
  static const String appName = 'ShowroomBaby';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String firstLaunchKey = 'first_launch';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image constraints
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImagesPerProduct = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Default values
  static const double defaultLatitude = 48.8566; // Paris
  static const double defaultLongitude = 2.3522;
  static const double searchRadius = 50.0; // km
  
  // Error messages
  static const String networkError = 'Erreur de connexion. Vérifiez votre internet.';
  static const String serverError = 'Erreur serveur. Veuillez réessayer plus tard.';
  static const String unknownError = 'Une erreur inattendue s\'est produite.';
  static const String authError = 'Session expirée. Veuillez vous reconnecter.';
  
  // Success messages
  static const String loginSuccess = 'Connexion réussie !';
  static const String registerSuccess = 'Inscription réussie !';
  static const String productAddedSuccess = 'Produit ajouté avec succès !';
  static const String profileUpdatedSuccess = 'Profil mis à jour avec succès !';
} 