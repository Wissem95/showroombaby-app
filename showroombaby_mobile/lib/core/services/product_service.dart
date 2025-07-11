import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/api_response.dart';
import '../models/filters.dart';
import '../../app/constants/api_constants.dart';

class ProductService {
  final Dio _dio;
  SharedPreferences? _prefs;

  ProductService(this._dio);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
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

  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    int limit = 10,
    ProductFilters? filters,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (filters != null) {
      if (filters.query != null) queryParams['query'] = filters.query;
      if (filters.categoryId != null) queryParams['categoryId'] = filters.categoryId;
      if (filters.minPrice != null) queryParams['minPrice'] = filters.minPrice;
      if (filters.maxPrice != null) queryParams['maxPrice'] = filters.maxPrice;
      if (filters.condition != null) queryParams['condition'] = filters.condition!.name;
      if (filters.latitude != null) queryParams['latitude'] = filters.latitude;
      if (filters.longitude != null) queryParams['longitude'] = filters.longitude;
      if (filters.radius != null) queryParams['radius'] = filters.radius;
      if (filters.sortBy != null) queryParams['sortBy'] = filters.sortBy;
    }

    final response = await _dio.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );

    return PaginatedResponse<Product>.fromJson(
      response.data,
      (json) => Product.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Product> getProduct(int id) async {
    final response = await _dio.get('${ApiConstants.products}/$id');
    return Product.fromJson(response.data['data']);
  }

  Future<List<Product>> getTrendingProducts() async {
    final response = await _dio.get(ApiConstants.trending);
    return (response.data['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  Future<List<Product>> getSimilarProducts(int productId) async {
    final response = await _dio.get('${ApiConstants.products}/$productId/similar');
    return (response.data['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  Future<Product> createProduct({
    required String title,
    required String description,
    required double price,
    required ProductCondition condition,
    required int categoryId,
    int? subcategoryId,
    String? brand,
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String zipcode,
    required String phone,
    required bool hidePhone,
    required List<String> imagePaths,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('price', price.toString()),
      MapEntry('condition', condition.name),
      MapEntry('categoryId', categoryId.toString()),
      MapEntry('latitude', latitude.toString()),
      MapEntry('longitude', longitude.toString()),
      MapEntry('address', address),
      MapEntry('city', city),
      MapEntry('zipcode', zipcode),
      MapEntry('phone', phone),
      MapEntry('hide_phone', hidePhone.toString()),
    ]);

    if (subcategoryId != null) {
      formData.fields.add(MapEntry('subcategoryId', subcategoryId.toString()));
    }

    if (brand != null) {
      formData.fields.add(MapEntry('brand', brand));
    }

    // Ajouter les images
    for (int i = 0; i < imagePaths.length; i++) {
      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(imagePaths[i]),
        ),
      );
    }

    final response = await _dio.post(
      ApiConstants.products,
      data: formData,
    );

    return Product.fromJson(response.data['data']);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.products}/$id', data: data);
    return Product.fromJson(response.data['data']);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('${ApiConstants.products}/$id');
  }

  Future<List<Product>> getUserProducts() async {
    final response = await _dio.get(
      '/users/me/products',
      options: Options(
        headers: await _getHeaders(),
      ),
    );
    return (response.data['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
} 