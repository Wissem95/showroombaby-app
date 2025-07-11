import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'base_providers.dart';

part 'category_provider.g.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoryService(dio);
});

/// Provider pour récupérer toutes les catégories
@riverpod
Future<List<Category>> categories(CategoriesRef ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getCategories();
}

/// Provider pour récupérer les compteurs de produits par catégorie
@riverpod
Future<Map<int, int>> categoryProductCounts(CategoryProductCountsRef ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getProductCountByCategory();
}

/// Provider pour récupérer les recherches récentes
@riverpod
Future<List<String>> recentSearches(RecentSearchesRef ref) async {
  final categoryService = ref.watch(categoryServiceProvider);
  return categoryService.getRecentSearches();
}

/// Provider pour gérer les actions sur les recherches récentes
@riverpod
class RecentSearchActions extends _$RecentSearchActions {
  @override
  void build() {
    // État initial vide
  }

  /// Ajoute une nouvelle recherche
  Future<void> addSearch(String query) async {
    final categoryService = ref.watch(categoryServiceProvider);
    await categoryService.saveRecentSearch(query);
    
    // Invalide le provider pour recharger les données
    ref.invalidate(recentSearchesProvider);
  }

  /// Efface toutes les recherches
  Future<void> clearAll() async {
    final categoryService = ref.watch(categoryServiceProvider);
    await categoryService.clearRecentSearches();
    
    // Invalide le provider pour recharger les données
    ref.invalidate(recentSearchesProvider);
  }
}

/// Provider pour effectuer une recherche de produits
@riverpod
Future<Map<String, dynamic>> searchProducts(
  SearchProductsRef ref, {
  required String query,
  int? categoryId,
  int page = 1,
  int limit = 10,
}) async {
  final categoryService = ref.watch(categoryServiceProvider);
  
  // Sauvegarder la recherche si elle n'est pas vide
  if (query.trim().isNotEmpty) {
    await categoryService.saveRecentSearch(query.trim());
    // Invalider le provider des recherches récentes pour le mettre à jour
    ref.invalidate(recentSearchesProvider);
  }
  
  return categoryService.searchProducts(
    query,
    categoryId: categoryId,
    page: page,
    limit: limit,
  );
}

/// Provider pour les catégories populaires (selon le nombre de produits)
@riverpod
Future<List<Category>> popularCategories(PopularCategoriesRef ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  final productCounts = await ref.watch(categoryProductCountsProvider.future);
  
  // Trier les catégories par nombre de produits (décroissant)
  final sortedCategories = [...categories];
  sortedCategories.sort((a, b) {
    final countA = productCounts[a.id] ?? 0;
    final countB = productCounts[b.id] ?? 0;
    return countB.compareTo(countA);
  });
  
  // Retourner les 6 catégories les plus populaires
  return sortedCategories.take(6).toList();
} 