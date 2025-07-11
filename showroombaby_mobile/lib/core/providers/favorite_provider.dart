import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product.dart';
import '../services/favorite_service.dart';
import 'base_providers.dart';

part 'favorite_provider.g.dart';

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  final dio = ref.watch(dioProvider);
  return FavoriteService(dio);
});

/// Provider pour récupérer la liste des favoris
@riverpod
Future<List<Product>> userFavorites(UserFavoritesRef ref) async {
  final favoriteService = ref.watch(favoriteServiceProvider);
  return favoriteService.getFavorites();
}

/// Provider pour vérifier si un produit est favori
@riverpod
Future<bool> isFavoriteProduct(IsFavoriteProductRef ref, int productId) async {
  final favoriteService = ref.watch(favoriteServiceProvider);
  return favoriteService.isFavorite(productId);
}

/// Provider pour gérer les actions sur les favoris
@riverpod
class FavoriteActions extends _$FavoriteActions {
  @override
  void build() {
    // Initial state
  }

  /// Bascule l'état favori d'un produit
  Future<bool> toggleFavorite(int productId) async {
    final favoriteService = ref.watch(favoriteServiceProvider);
    final result = await favoriteService.toggleFavorite(productId);
    
    // Invalider les providers liés pour mettre à jour l'UI
    ref.invalidate(userFavoritesProvider);
    ref.invalidate(isFavoriteProductProvider(productId));
    
    return result;
  }

  /// Ajouter aux favoris
  Future<void> addToFavorites(int productId) async {
    final favoriteService = ref.watch(favoriteServiceProvider);
    await favoriteService.addToFavorites(productId);
    
    // Invalider les providers liés
    ref.invalidate(userFavoritesProvider);
    ref.invalidate(isFavoriteProductProvider(productId));
  }

  /// Supprimer des favoris
  Future<void> removeFromFavorites(int productId) async {
    final favoriteService = ref.watch(favoriteServiceProvider);
    await favoriteService.removeFromFavorites(productId);
    
    // Invalider les providers liés
    ref.invalidate(userFavoritesProvider);
    ref.invalidate(isFavoriteProductProvider(productId));
  }
} 