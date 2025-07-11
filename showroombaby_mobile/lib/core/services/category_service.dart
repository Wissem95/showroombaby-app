import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/api_constants.dart';
import '../models/category.dart';
import '../models/api_response.dart';

class CategoryService {
  final Dio _dio;
  SharedPreferences? _prefs;

  CategoryService(this._dio);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Récupère toutes les catégories avec leurs sous-catégories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/categories',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        // L'API peut retourner soit un array direct, soit un objet avec 'data'
        final responseData = response.data;
        
        List<dynamic> categoriesData;
        if (responseData is List) {
          // API retourne directement un array
          categoriesData = responseData;
        } else if (responseData is Map && responseData['data'] != null) {
          // API retourne un objet avec 'data'
          categoriesData = responseData['data'] as List<dynamic>;
        } else {
          throw Exception('Format de réponse inattendu pour les catégories');
        }
        
        return categoriesData
            .map((json) => Category.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors du chargement des catégories');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère le nombre de produits par catégorie
  Future<Map<int, int>> getProductCountByCategory() async {
    try {
      final categories = await getCategories();
      final Map<int, int> productCounts = {};

      // Pour chaque catégorie, compter les produits
      for (final category in categories) {
        final response = await _dio.get(
          '${ApiConstants.baseUrl}/products',
          queryParameters: {
            'categoryId': category.id,
            'limit': 1, // On ne veut que le compteur, pas les produits
          },
          options: Options(
            headers: await _getHeaders(),
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            // Essayer plusieurs clés possibles pour le total
            productCounts[category.id] = data['total'] ?? data['meta']?['total'] ?? 0;
          } else {
            productCounts[category.id] = 0;
          }
        }
      }

      return productCounts;
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Recherche des produits par terme
  Future<Map<String, dynamic>> searchProducts(String query, {
    int? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/products',
        queryParameters: {
          'query': query,
          if (categoryId != null) 'categoryId': categoryId,
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la recherche');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Sauvegarde une recherche récente
  Future<void> saveRecentSearch(String query) async {
    final prefs = await _getPrefs();
    final recentSearches = await getRecentSearches();
    
    // Supprimer la recherche si elle existe déjà
    recentSearches.removeWhere((search) => search.toLowerCase() == query.toLowerCase());
    
    // Ajouter en premier
    recentSearches.insert(0, query);
    
    // Garder seulement les 10 dernières recherches
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    
    await prefs.setStringList('recent_searches', recentSearches);
  }

  /// Récupère les recherches récentes
  Future<List<String>> getRecentSearches() async {
    final prefs = await _getPrefs();
    return prefs.getStringList('recent_searches') ?? [];
  }

  /// Efface toutes les recherches récentes
  Future<void> clearRecentSearches() async {
    final prefs = await _getPrefs();
    await prefs.remove('recent_searches');
  }

  /// Headers pour les requêtes API
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