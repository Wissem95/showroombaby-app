import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/category.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/product.dart' show ProductCondition;

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialSearchQuery;
  final int? initialCategoryId;
  
  const HomeScreen({
    super.key,
    this.initialSearchQuery,
    this.initialCategoryId,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? selectedCategoryId; // Pour suivre la catégorie sélectionnée
  String? currentSearchQuery; // Pour suivre le terme de recherche actuel
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Initialiser avec les paramètres passés
    selectedCategoryId = widget.initialCategoryId;
    currentSearchQuery = widget.initialSearchQuery;
    
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Détermine quel provider utiliser selon l'état actuel
    final AsyncValue<List<Product>> productsAsync;
    
    if (currentSearchQuery != null && currentSearchQuery!.isNotEmpty) {
      // Si on a un terme de recherche, utiliser le provider de recherche
      productsAsync = ref.watch(searchProductsListProvider(currentSearchQuery!));
    } else if (selectedCategoryId != null) {
      // Sinon si une catégorie est sélectionnée, utiliser le provider de catégorie
      productsAsync = ref.watch(categoryProductsProvider(selectedCategoryId!));
    } else {
      // Sinon, charger les produits tendance par défaut
      productsAsync = ref.watch(trendingProductsProvider);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Bleu très clair
              Color(0xFFF3E5F5), // Violet très clair
              Color(0xFFFFF3E0), // Orange très clair
              Color(0xFFE8F5E8), // Vert très clair
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
                      child: RefreshIndicator(
              onRefresh: () async {
                if (currentSearchQuery != null && currentSearchQuery!.isNotEmpty) {
                  ref.invalidate(searchProductsListProvider(currentSearchQuery!));
                } else if (selectedCategoryId != null) {
                  ref.invalidate(categoryProductsProvider(selectedCategoryId!));
                } else {
                  ref.invalidate(trendingProductsProvider);
                }
              },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Barre de recherche en haut comme dans la première image
                  _buildTopSearchBar(context),
                  
                  const SizedBox(height: 40),

                  // Section tendances comme dans la première image
                  _buildTrendingSection(context, ref, productsAsync),

                  const SizedBox(height: 100), // Espace pour le bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                // Plus transparente avec effet fondu
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30), // Plus arrondi
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: currentSearchQuery != null && currentSearchQuery!.isNotEmpty 
                      ? 'Recherche: $currentSearchQuery'
                      : 'Rechercher un produit...',
                  hintStyle: TextStyle(
                    color: currentSearchQuery != null && currentSearchQuery!.isNotEmpty 
                        ? AppColors.primary 
                        : Colors.grey,
                    fontSize: 16,
                    fontWeight: currentSearchQuery != null && currentSearchQuery!.isNotEmpty 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 24,
                  ),
                  suffixIcon: currentSearchQuery != null && currentSearchQuery!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onSubmitted: _performSearch,
                onChanged: (value) {
                  // Recherche en temps réel si l'utilisateur fait une pause
                  if (value.isEmpty) {
                    _clearSearch();
                  }
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              // Plus transparent avec effet fondu
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30), // Plus arrondi
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => context.push('/login'),
              child: const Text(
                "S'identifier",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> productsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            currentSearchQuery != null && currentSearchQuery!.isNotEmpty
                ? 'Résultats pour "${currentSearchQuery}"'
                : selectedCategoryId == null 
                    ? 'Surfer sur les tendances !'
                    : 'Produits filtrés',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Pastilles de catégories
        _buildCategoryPills(context, ref),
        
        const SizedBox(height: 24),
        productsAsync.when(
          data: (products) => _buildProductGrid(context, products, ref),
          loading: () => const Center(
            child: LoadingWidget(message: 'Chargement...'),
          ),
          error: (error, stack) {
            print('Erreur chargement produits: $error');
            return _buildErrorState(context, ref, error.toString());
          },
        ),
      ],
    );
  }

  // Méthodes pour la recherche
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }
    
    setState(() {
      currentSearchQuery = query.trim();
      selectedCategoryId = null; // Réinitialiser la catégorie sélectionnée
      _searchController.text = query.trim();
    });
  }

  void _clearSearch() {
    setState(() {
      currentSearchQuery = null;
      _searchController.clear();
    });
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products, WidgetRef ref) {
    // Si aucun produit, afficher un message avec le background qui continue
    if (products.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product, ref);
      },
    );
  }

  /// Widget d'état vide quand aucun produit n'est trouvé
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône avec effet de transparence
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Titre principal
          Text(
            currentSearchQuery != null && currentSearchQuery!.isNotEmpty
                ? 'Aucun résultat trouvé'
                : selectedCategoryId == null 
                    ? 'Aucun produit tendance'
                    : 'Aucun produit trouvé',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Message descriptif
          Text(
            currentSearchQuery != null && currentSearchQuery!.isNotEmpty
                ? 'Aucun produit ne correspond à votre recherche "${currentSearchQuery}".\nEssayez avec d\'autres mots-clés.'
                : selectedCategoryId == null
                    ? 'Les produits tendance ne sont pas disponibles pour le moment.'
                    : 'Il n\'y a pas encore de produits dans cette catégorie.\nRevenez plus tard ou explorez d\'autres catégories !',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Bouton pour effacer la recherche ou revenir aux tendances
          if (currentSearchQuery != null && currentSearchQuery!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _clearSearch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Effacer la recherche',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (selectedCategoryId != null)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    setState(() {
                      selectedCategoryId = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Voir les tendances',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, WidgetRef ref) {
    final displayPrice = product.price ?? 0.0; // Gérer le cas null
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/product/${product.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit avec bouton favori
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isFavoriteAsync = ref.watch(isFavoriteProductProvider(product.id));
                        
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: isFavoriteAsync.when(
                              data: (isFavorite) => Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              loading: () => const Icon(
                                Icons.favorite_border,
                                color: Colors.grey,
                              ),
                              error: (_, __) => const Icon(
                                Icons.favorite_border,
                                color: Colors.grey,
                              ),
                            ),
                            onPressed: () => _toggleFavorite(context, ref, product),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              // Informations du produit
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du produit
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Prix
                      Text(
                        product.price != null 
                            ? '${displayPrice.toStringAsFixed(2)} €'
                            : 'Prix à négocier',
                        style: TextStyle(
                          color: product.price != null ? AppColors.primary : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Localisation
                      Text(
                        product.city ?? 'Localisation non spécifiée',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                const Icon(Icons.home, size: 24),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 24),
            label: 'Recherche',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 24),
            label: 'Favoris',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Déjà sur l'accueil
              break;
            case 1:
              context.push('/search');
              break;
            case 2:
              context.push('/favorites');
              break;
            case 3:
              context.push('/messages');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

    /// Construit les pastilles de catégories filtrables
  Widget _buildCategoryPills(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
         // Ajouter une catégorie "Tous" en premier
         final allCategories = [
           Category(id: 0, name: 'Tous', icon: '🏠'),
           ...categories,
         ];
        
        return Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              // Une pastille est sélectionnée seulement si on n'est pas en mode recherche
              final isSelected = currentSearchQuery == null && 
                               ((category.id == 0 && selectedCategoryId == null) ||
                                (category.id != 0 && selectedCategoryId == category.id));
              return _buildCategoryPill(context, ref, category, isSelected);
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Construit une pastille de catégorie individuelle
  Widget _buildCategoryPill(BuildContext context, WidgetRef ref, Category category, bool isSelected) {
    final Map<String, Color> categoryColors = {
      'Tous': Colors.blue,
      'Poussette': Colors.green,
      'Jeux/Éveil': Colors.orange,
      'Toilette': Colors.purple,
    };
    
    final Color color = categoryColors[category.name] ?? Colors.grey;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            setState(() {
              // Effacer la recherche quand on clique sur une catégorie
              currentSearchQuery = null;
              _searchController.clear();
              
              if (category.id == 0) {
                // Afficher tous les produits (tendances)
                selectedCategoryId = null;
              } else {
                // Filtrer par catégorie
                selectedCategoryId = category.id;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              // Style différent selon l'état sélectionné
              color: isSelected 
                  ? color.withOpacity(0.3) // Plus opaque si sélectionné
                  : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? color.withOpacity(0.8) // Bordure plus foncée si sélectionné
                    : color.withOpacity(0.3),
                width: isSelected ? 2.0 : 1.5, // Bordure plus épaisse si sélectionné
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de la catégorie
                Text(
                  category.icon ?? '📦',
                  style: TextStyle(
                    fontSize: isSelected ? 18 : 16, // Plus grande si sélectionnée
                  ),
                ),
                const SizedBox(width: 8),
                // Nom de la catégorie
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected 
                        ? color // Couleur plus foncée si sélectionné
                        : color.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget d'état d'erreur avec le background qui continue
  Widget _buildErrorState(BuildContext context, WidgetRef ref, String errorMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône d'erreur avec effet de transparence
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Titre
          const Text(
            'Oops !',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Message d'erreur
          Text(
            'Une erreur s\'est produite lors du chargement.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Bouton réessayer
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  if (selectedCategoryId != null) {
                    ref.invalidate(categoryProductsProvider(selectedCategoryId!));
                  } else {
                    ref.invalidate(trendingProductsProvider);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Réessayer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(BuildContext context, WidgetRef ref, Product product) async {
    try {
      final favoriteActions = ref.read(favoriteActionsProvider.notifier);
      await favoriteActions.toggleFavorite(product.id);
      
      // Invalider les providers pour rafraîchir l'UI
      ref.invalidate(userFavoritesProvider);
      ref.invalidate(isFavoriteProductProvider(product.id));
      
      // Afficher un message de confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit ${await ref.read(isFavoriteProductProvider(product.id).future) ? "ajouté aux" : "retiré des"} favoris'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 