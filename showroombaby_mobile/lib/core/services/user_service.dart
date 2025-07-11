import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/api_constants.dart';
import '../models/user.dart';

class UserService {
  final Dio _dio;
  SharedPreferences? _prefs;

  UserService(this._dio);

  /// Lazy initialization de SharedPreferences
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Récupère le profil d'un utilisateur spécifique
  Future<User?> getUserProfile(int userId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/users/$userId',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          // Si les données sont dans 'data', sinon directement
          final userData = responseData['data'] ?? responseData;
          return User.fromJson(userData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      // En cas d'erreur, retourner null
      return null;
    }
  }

  /// Headers pour les requêtes API avec token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
} 