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
    print('ProductList: loadMore appelé');
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

/// Provider pour récupérer les détails d'un produit spécifique
@riverpod
Future<Product> productDetails(ProductDetailsRef ref, int productId) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getProduct(productId);
}

@riverpod
Future<List<Product>> similarProducts(SimilarProductsRef ref, int productId) async {
  final service = ref.read(productServiceProvider);
  return await service.getSimilarProducts(productId);
}

@riverpod
Future<List<Product>> userProducts(UserProductsRef ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getUserProducts();
}

/// Provider pour récupérer les produits d'un utilisateur spécifique
@riverpod
Future<List<Product>> userProductsById(UserProductsByIdRef ref, int userId) async {
  final service = ref.read(productServiceProvider);
  return await service.getUserProductsById(userId);
}

@riverpod
Future<List<Product>> categoryProducts(CategoryProductsRef ref, int categoryId) async {
  final service = ref.read(productServiceProvider);
  final filters = ProductFilters(categoryId: categoryId);
  final result = await service.getProducts(filters: filters);
  return result.items;
}

@riverpod
Future<List<Product>> searchProductsList(SearchProductsListRef ref, String query) async {
  final service = ref.read(productServiceProvider);
  final filters = ProductFilters(query: query);
  final result = await service.getProducts(filters: filters);
  return result.items;
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