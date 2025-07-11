class ApiConstants {
  // Base URL - URL de votre backend Laravel local
  static const String baseUrl = 'http://localhost:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String checkAuth = '/auth/check';
  static const String refreshToken = '/auth/refresh';

  // Products endpoints
  static const String products = '/products';
  static const String trending = '/products/trending';
  static const String similar = '/products/similar';
  static const String search = '/products/search';

  // Categories endpoints
  static const String categories = '/categories';
  static const String subcategories = '/categories/subcategories';

  // Messages endpoints
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';
  static const String sendMessage = '/messages/send';

  // Favorites endpoints
  static const String favorites = '/favorites';
  static const String addFavorite = '/favorites/add';
  static const String removeFavorite = '/favorites/remove';

  // Users endpoints
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile/update';
  static const String users = '/users';

  // Reports endpoints
  static const String reports = '/reports';
  static const String reportProduct = '/reports/product';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/mark-read';

  // Upload endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadMultiple = '/upload/multiple';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
} 