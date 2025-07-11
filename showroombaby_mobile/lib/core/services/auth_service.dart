import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../../app/constants/api_constants.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthService(this._dio, this._prefs) {
    // Charger le token existant au démarrage
    _loadExistingToken();
  }

  // Charger le token existant et le configurer dans Dio
  void _loadExistingToken() {
    final token = _prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Sauvegarder le token
      await _saveToken(authResponse.accessToken);
      await _saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'password_confirmation': password,
          'username': username,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Sauvegarder le token
      await _saveToken(authResponse.accessToken);
      await _saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignorer les erreurs de logout côté serveur
    } finally {
      await _clearSession();
    }
  }

  Future<User?> checkAuth() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(ApiConstants.checkAuth);
      return User.fromJson(response.data['user']);
    } catch (e) {
      await _clearSession();
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    await _prefs.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<User?> getStoredUser() async {
    final userData = _prefs.getString('user_data');
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData);
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearSession() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_data');
    _dio.options.headers.remove('Authorization');
  }

  String _handleAuthError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 422) {
        final errors = error.response?.data['errors'];
        if (errors != null) {
          return errors.values.first[0];
        }
      } else if (error.response?.statusCode == 401) {
        return 'Email ou mot de passe incorrect';
      }
    }
    return 'Une erreur est survenue';
  }
} 