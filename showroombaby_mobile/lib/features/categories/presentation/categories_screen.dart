import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/category_provider.dart';
import '../../../core/models/category.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../app/theme/app_colors.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

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
        return Colors.blue[600]!;
      case 'sièges auto':
        return Colors.red[600]!;
      case 'chambre':
        return Colors.purple[600]!;
      case 'chaussure / vêtements':
        return Colors.green[600]!;
      case 'jeux / éveil':
        return Colors.orange[600]!;
      case 'livre / dvd':
        return Colors.teal[600]!;
      case 'toilette':
        return Colors.cyan[600]!;
      case 'repas':
        return Colors.amber[700]!;
      case 'sortie':
        return Colors.indigo[600]!;
      case 'service':
        return Colors.brown[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch des providers pour les données temps réel
    final categoriesAsync = ref.watch(categoriesProvider);
    final productCountsAsync = ref.watch(categoryProductCountsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Catégories',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return productCountsAsync.when(
            data: (productCounts) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec statistiques
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Découvrez nos catégories',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${categories.length} catégories disponibles',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.category,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Grid des catégories avec vraies données
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final productCount = productCounts[category.id] ?? 0;

                        return InkWell(
                          onTap: () {
                            context.push('/category/${category.id}?name=${Uri.encodeComponent(category.name)}');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icône colorée avec gradient
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _getCategoryColor(category.name),
                                        _getCategoryColor(category.name).withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getCategoryColor(category.name).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category.name),
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Nom de la catégorie
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Nombre de produits (données réelles)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: productCount > 0 
                                        ? _getCategoryColor(category.name).withOpacity(0.1)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    productCount > 0
                                        ? '$productCount produit${productCount > 1 ? 's' : ''}'
                                        : 'Bientôt disponible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: productCount > 0 
                                          ? _getCategoryColor(category.name)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Section promotion ou conseils
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Conseils ShowroomBaby',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Trouvez facilement ce que vous cherchez en naviguant par catégorie. Chaque produit est vérifié par notre équipe.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
    );
  }
} 