import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/auth_provider.dart';

// Auth
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';

// Home
import '../../features/home/presentation/home_screen.dart';

// Products
import '../../features/products/presentation/product_details_screen.dart';
import '../../features/products/presentation/add_product_screen.dart';
import '../../features/products/presentation/edit_product_screen.dart';
import '../../features/products/presentation/trending_products_screen.dart';

// Search
import '../../features/search/presentation/search_screen.dart';
import '../../features/search/presentation/search_results_screen.dart';

// Favorites
import '../../features/favorites/presentation/favorites_screen.dart';

// Messages
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/messages/presentation/conversation_screen.dart';

// Profile
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/user_products_screen.dart';
import '../../features/profile/presentation/user_profile_screen.dart';

// Categories
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/categories/presentation/category_products_screen.dart';

// Notifications
import '../../features/notifications/presentation/notifications_screen.dart';

// Settings & Legal
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/help/presentation/help_screen.dart';
import '../../features/legal/presentation/terms_screen.dart';
import '../../features/legal/presentation/privacy_screen.dart';

part 'app_router.g.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: isAuthenticated ? '/' : '/login',
    redirect: (context, state) {
      final isAuth = ref.read(isAuthenticatedProvider);
      final isLoggingIn = ['/login', '/register'].contains(state.fullPath);

      // Si pas authentifié et pas sur login/register
      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      // Si authentifié et sur login/register
      if (isAuth && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // === Routes d'authentification ===
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // === Routes principales (nécessitent authentification) ===
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final searchQuery = state.uri.queryParameters['q'];
          final categoryId = state.uri.queryParameters['categoryId'];
          return HomeScreen(
            initialSearchQuery: searchQuery,
            initialCategoryId: categoryId != null ? int.tryParse(categoryId) : null,
          );
        },
      ),

      // === Routes des produits ===
      GoRoute(
        path: '/product/:id',
        name: 'product-details',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailsScreen(productId: id);
        },
      ),

      GoRoute(
        path: '/add-product',
        name: 'add-product',
        builder: (context, state) => const AddProductScreen(),
      ),

      GoRoute(
        path: '/edit-product/:id',
        name: 'edit-product',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditProductScreen(productId: id);
        },
      ),

      // === Routes de recherche ===
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      GoRoute(
        path: '/search/results',
        name: 'search-results',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsScreen(query: query);
        },
      ),

      // === Routes des catégories ===
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      GoRoute(
        path: '/category/:id',
        name: 'category-products',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final name = state.uri.queryParameters['name'] ?? '';
          return CategoryProductsScreen(categoryId: id, categoryName: name);
        },
      ),

      // === Routes des favoris ===
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),

      // === Routes des messages ===
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MessagesScreen(),
      ),

      GoRoute(
        path: '/messages/conversation/:userId',
        name: 'conversation',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final productId = state.uri.queryParameters['productId'];
          return ConversationScreen(
            userId: userId,
            productId: productId != null ? int.parse(productId) : null,
          );
        },
      ),

      // === Routes du profil ===
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: '/profile/products',
        name: 'user-products',
        builder: (context, state) => const UserProductsScreen(),
      ),

      GoRoute(
        path: '/user/:id',
        name: 'user-profile',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return UserProfileScreen(userId: id);
        },
      ),

      // === Routes des notifications ===
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // === Routes de navigation par onglets ===
      GoRoute(
        path: '/trending',
        name: 'trending',
        builder: (context, state) => const TrendingProductsScreen(),
      ),

      // === Routes de gestion ===
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),

      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),

      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],

    // Gestion des erreurs de navigation
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page non trouvée',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'La page "${state.uri}" n\'existe pas.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

// === Extensions pour faciliter la navigation ===
extension AppRouterExtension on GoRouter {
  void pushProduct(int productId) {
    push('/product/$productId');
  }

  void pushConversation(int userId, {int? productId}) {
    final query = productId != null ? '?productId=$productId' : '';
    push('/messages/conversation/$userId$query');
  }

  void pushUserProfile(int userId) {
    push('/user/$userId');
  }

  void pushCategoryProducts(int categoryId, String categoryName) {
    push('/category/$categoryId?name=${Uri.encodeComponent(categoryName)}');
  }

  void pushSearchResults(String query) {
    push('/search/results?q=${Uri.encodeComponent(query)}');
  }
}

// === Navigation Helper Provider ===
@riverpod
NavigationHelper navigationHelper(NavigationHelperRef ref) {
  return NavigationHelper(ref);
}

class NavigationHelper {
  final Ref ref;

  NavigationHelper(this.ref);

  GoRouter get router => ref.read(appRouterProvider);

  // Méthodes de navigation simplifiées
  void goToHome() => router.go('/');
  void goToLogin() => router.go('/login');
  void goToProfile() => router.go('/profile');
  void goToMessages() => router.go('/messages');
  void goToFavorites() => router.go('/favorites');
  void goToSearch() => router.go('/search');
  void goToNotifications() => router.go('/notifications');

  // Méthodes avec paramètres
  void goToProduct(int productId) => router.pushProduct(productId);
  void goToConversation(int userId, {int? productId}) =>
      router.pushConversation(userId, productId: productId);
  void goToUserProfile(int userId) => router.pushUserProfile(userId);
  void goToCategoryProducts(int categoryId, String categoryName) =>
      router.pushCategoryProducts(categoryId, categoryName);
  void goToSearchResults(String query) => router.pushSearchResults(query);

  // Navigation avec authentification
  void requireAuth(VoidCallback action) {
    final isAuth = ref.read(isAuthenticatedProvider);
    if (isAuth) {
      action();
    } else {
      goToLogin();
    }
  }

  // Navigation retour avec fallback
  void goBackOrHome(BuildContext context) {
    if (router.canPop()) {
      router.pop();
    } else {
      goToHome();
    }
  }
}

// === Constants pour les routes ===
class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';

  // Main
  static const home = '/';
  static const search = '/search';
  static const favorites = '/favorites';
  static const messages = '/messages';
  static const profile = '/profile';

  // Products
  static const addProduct = '/add-product';
  static const trending = '/trending';

  // Other
  static const categories = '/categories';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const help = '/help';
  static const terms = '/terms';
  static const privacy = '/privacy';
} 