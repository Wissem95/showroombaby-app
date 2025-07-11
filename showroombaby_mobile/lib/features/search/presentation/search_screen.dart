import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/category_provider.dart';
import '../../../core/models/category.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../app/theme/app_colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus automatique sur la barre de recherche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Icônes par catégorie
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'poussette':
        return Icons.baby_changing_station;
      case 'sièges auto':
        return Icons.car_rental;
      case 'chambre':
        return Icons.bedroom_baby;
      case 'chaussure / vêtements':
        return Icons.checkroom;
      case 'jeux / éveil':
        return Icons.toys;
      case 'livre / dvd':
        return Icons.menu_book;
      case 'toilette':
        return Icons.bathtub;
      case 'repas':
        return Icons.restaurant;
      case 'sortie':
        return Icons.backpack;
      case 'service':
        return Icons.support_agent;
      default:
        return Icons.category;
    }
  }

  // Couleurs par catégorie
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'poussette':
        return Colors.blue[400]!;
      case 'sièges auto':
        return Colors.red[400]!;
      case 'chambre':
        return Colors.purple[400]!;
      case 'chaussure / vêtements':
        return Colors.green[400]!;
      case 'jeux / éveil':
        return Colors.orange[400]!;
      case 'livre / dvd':
        return Colors.teal[400]!;
      case 'toilette':
        return Colors.cyan[400]!;
      case 'repas':
        return Colors.amber[400]!;
      case 'sortie':
        return Colors.indigo[400]!;
      case 'service':
        return Colors.brown[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Sauvegarder la recherche dans les recherches récentes
      ref.read(recentSearchActionsProvider.notifier).addSearch(query.trim());
      
      // Rediriger vers la homepage avec le terme de recherche
      context.go('/?q=${Uri.encodeComponent(query.trim())}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch des providers pour les données temps réel
    final popularCategoriesAsync = ref.watch(popularCategoriesProvider);
    final productCountsAsync = ref.watch(categoryProductCountsProvider);
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recherche',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recherches récentes
                  recentSearchesAsync.when(
                    data: (recentSearches) {
                      if (recentSearches.isEmpty) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recherches récentes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(recentSearchActionsProvider.notifier).clearAll();
                                },
                                child: const Text(
                                  'Effacer',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: recentSearches.map((search) {
                              return InkWell(
                                onTap: () => _performSearch(search),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.history,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        search,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // Catégories populaires avec vraies données
                  const Text(
                    'Catégories populaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid des catégories avec données API
                  popularCategoriesAsync.when(
                    data: (categories) {
                      return productCountsAsync.when(
                        data: (productCounts) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final productCount = productCounts[category.id] ?? 0;
                              
                              return InkWell(
                                onTap: () {
                                  context.go('/?categoryId=${category.id}');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icône colorée de la catégorie
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(category.name).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(category.name),
                                          color: _getCategoryColor(category.name),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Nom de la catégorie
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Nombre de produits (données réelles)
                                      Text(
                                        productCount > 0 
                                            ? '$productCount produit${productCount > 1 ? 's' : ''}'
                                            : 'Aucun produit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const LoadingWidget(),
                        error: (error, stack) => const CustomErrorWidget(
                          message: 'Erreur lors du chargement des compteurs',
                        ),
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (error, stack) => const CustomErrorWidget(
                      message: 'Erreur lors du chargement des catégories',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recherches tendances (optionnel - peut rester fictif ou être retiré)
                  const Text(
                    'Recherches tendances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quelques suggestions basiques
                  Column(
                    children: [
                      'Poussette Cybex',
                      'Vêtements 6 mois',
                      'Jouets en bois',
                      'Lit bébé',
                    ].map((trend) {
                      return ListTile(
                        onTap: () => _performSearch(trend),
                        leading: const Icon(
                          Icons.trending_up,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        title: Text(
                          trend,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 