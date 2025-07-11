import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/api_constants.dart';
import '../models/product.dart';
import '../models/api_response.dart';

class FavoriteService {
  final Dio _dio;
  SharedPreferences? _prefs;

  FavoriteService(this._dio);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Récupère tous les favoris de l'utilisateur
  Future<List<Product>> getFavorites() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/favorites',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          final favoritesList = responseData['data'] as List;
          return favoritesList
              .map((item) => Product.fromJson(item['product'] as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Format de réponse inattendu pour les favoris');
        }
      } else {
        throw Exception('Erreur lors du chargement des favoris');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour voir vos favoris');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Ajoute un produit aux favoris
  Future<void> addToFavorites(int productId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/favorites/$productId',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Erreur lors de l\'ajout aux favoris');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour ajouter des favoris');
      } else if (e.response?.statusCode == 422) {
        // Erreur de validation - extraire le message du serveur
        final errorMessage = e.response?.data?['message'] ?? 
                            'Impossible d\'ajouter ce produit aux favoris';
        throw Exception(errorMessage);
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Supprime un produit des favoris
  Future<void> removeFromFavorites(int productId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/favorites/$productId',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du favori');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour gérer vos favoris');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Vérifie si un produit est dans les favoris
  Future<bool> isFavorite(int productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/favorites/check/$productId',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['isFavorite'] ?? false; // Correction du nom de clé
        }
      }
      return false;
    } on DioException catch (e) {
      // Si erreur, considérer comme non favori
      print('Erreur lors de la vérification du favori: ${e.message}');
      return false;
    }
  }

  /// Bascule l'état favori d'un produit
  Future<bool> toggleFavorite(int productId) async {
    final isFav = await isFavorite(productId);
    
    if (isFav) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
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