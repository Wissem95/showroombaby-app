# 🛍️ Gestion des Produits - ShowroomBaby

## Service et Provider Produits

### 1. Product Service (core/services/product_service.dart)

```dart
import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/api_response.dart';
import '../models/filters.dart';
import '../../app/constants/api_constants.dart';

class ProductService {
  final Dio _dio;

  ProductService(this._dio);

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
    final response = await _dio.get('/users/me/products');
    return (response.data['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
}
```

### 2. Product Provider (core/providers/product_provider.dart)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product.dart';
import '../models/filters.dart';
import '../services/product_service.dart';
import 'base_providers.dart';

part 'product_provider.g.dart';

@riverpod
ProductService productService(ProductServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return ProductService(dio);
}

@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<Product>> build() async {
    final service = ref.read(productServiceProvider);
    final result = await service.getProducts();
    return result.items;
  }

  Future<void> loadMore() async {
    // Implémentation du chargement de plus de produits
    // avec pagination
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> applyFilters(ProductFilters filters) async {
    final service = ref.read(productServiceProvider);
    final result = await service.getProducts(filters: filters);
    state = AsyncValue.data(result.items);
  }
}

@riverpod
Future<List<Product>> trendingProducts(TrendingProductsRef ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getTrendingProducts();
}

@riverpod
Future<Product> productDetails(ProductDetailsRef ref, int productId) async {
  final service = ref.read(productServiceProvider);
  return await service.getProduct(productId);
}

@riverpod
Future<List<Product>> similarProducts(SimilarProductsRef ref, int productId) async {
  final service = ref.read(productServiceProvider);
  return await service.getSimilarProducts(productId);
}

@riverpod
class ProductFiltersNotifier extends _$ProductFiltersNotifier {
  @override
  ProductFilters build() {
    return const ProductFilters();
  }

  void updateFilters(ProductFilters filters) {
    state = filters;
  }

  void clearFilters() {
    state = const ProductFilters();
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateCondition(ProductCondition? condition) {
    state = state.copyWith(condition: condition);
  }

  void updateLocation(double? latitude, double? longitude, double? radius) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  void updateSorting(String? sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }
}
```

Cette première partie établit les services et providers pour la gestion des produits.

Continuez avec le fichier 06_PRODUCTS_UI.md pour les écrans d'interface utilisateur.
