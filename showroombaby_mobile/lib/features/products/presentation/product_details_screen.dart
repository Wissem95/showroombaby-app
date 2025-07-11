import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/models/product.dart';
import '../../../core/models/product_image.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../app/theme/app_colors.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final similarAsync = ref.watch(similarProductsProvider(productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) => _buildProductDetails(context, ref, product, similarAsync),
        loading: () => const LoadingWidget(message: 'Chargement du produit...'),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailsProvider(productId)),
        ),
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    WidgetRef ref,
    Product product,
    AsyncValue<List<Product>> similarAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar avec images
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageCarousel(product.images),
          ),
                    actions: [
            Consumer(
              builder: (context, ref, child) {
                final isFavoriteAsync = ref.watch(isFavoriteProductProvider(product.id));
                
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isFavoriteAsync.when(
                      data: (isFavorite) => Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      loading: () => const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      error: (_, __) => const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _toggleFavorite(context, ref, product),
                  ),
                );
              },
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Partager'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: ListTile(
                      leading: Icon(Icons.report),
                      title: Text('Signaler'),
                    ),
                  ),
                ],
                onSelected: (value) => _handleMenuAction(context, value, product),
              ),
            ),
          ],
        ),

        // Contenu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et prix
                _buildTitleAndPrice(context, product),

                const SizedBox(height: 16),

                // Informations du vendeur
                _buildSellerInfo(context, product),

                const SizedBox(height: 16),

                // Description
                _buildDescription(context, product),

                const SizedBox(height: 16),

                // Détails du produit
                _buildProductDetailsCard(context, product),

                const SizedBox(height: 24),

                // Boutons d'action
                _buildActionButtons(context, product),

                const SizedBox(height: 32),

                // Produits similaires
                _buildSimilarProducts(context, ref, similarAsync),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<ProductImage> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.image,
          size: 80,
          color: Colors.grey,
        ),
      );
    }

    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return CachedNetworkImage(
          imageUrl: image.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleAndPrice(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.price != null 
              ? '${product.price!.toStringAsFixed(2)} €'
              : 'Prix à négocier',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: product.price != null ? AppColors.price : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInfo(BuildContext context, Product product) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: product.seller?.avatar != null
              ? NetworkImage(product.seller!.avatar!)
              : null,
          child: product.seller?.avatar == null
              ? Text(
                  // Utiliser le nom du seller, sinon créer des initiales avec l'ID
                  product.seller?.name?.substring(0, 1).toUpperCase() ?? 
                  product.seller?.username?.substring(0, 1).toUpperCase() ?? 
                  'U${product.userId}'.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          // Afficher le nom du vendeur, sinon son username, sinon "Vendeur ID"
          product.seller?.name ?? 
          product.seller?.username ?? 
          'Vendeur ${product.userId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              product.seller?.rating?.toStringAsFixed(1) ?? '4.5',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                // Utiliser la ville du vendeur, sinon celle du produit
                product.seller?.city ?? product.city ?? 'Localisation non spécifiée',
                style: TextStyle(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Naviguer vers le profil du vendeur en utilisant userId
          context.push('/user/${product.userId}');
        },
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProductDetailsCard(BuildContext context, Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('État', _getConditionText(product.condition)),
            _buildDetailRow('Catégorie', product.category?.name ?? 'Non spécifié'),
            if (product.brand != null)
              _buildDetailRow('Marque', product.brand!),
            _buildDetailRow('Publié le', _formatDate(product.createdAt)),
            _buildDetailRow('Vues', '${product.viewCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Product product) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Contacter',
            icon: const Icon(Icons.chat, size: 20),
            onPressed: () => _contactSeller(context, product),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: product.hidePhone ? 'Téléphone masqué' : 'Appeler',
            icon: Icon(
              product.hidePhone ? Icons.phone_disabled : Icons.phone, 
              size: 20
            ),
            isOutlined: true,
            onPressed: product.hidePhone ? null : () => _callSeller(context, product),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProducts(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> similarAsync,
  ) {
    return similarAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produits similaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  String _getConditionText(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newCondition:
        return 'Neuf';
      case ProductCondition.likeNew:
        return 'Comme neuf';
      case ProductCondition.good:
        return 'Bon état';
      case ProductCondition.fair:
        return 'État correct';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non spécifié';
    return '${date.day}/${date.month}/${date.year}';
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

  void _handleMenuAction(BuildContext context, String action, Product product) {
    switch (action) {
      case 'share':
        // Implémentation partage
        print('Partager produit: ${product.title}');
        break;
      case 'report':
        // Implémentation signalement
        print('Signaler produit: ${product.title}');
        break;
    }
  }

  void _contactSeller(BuildContext context, Product product) {
    // Utiliser product.userId qui est toujours présent, au lieu de product.seller?.id qui peut être null
    if (product.userId > 0) {
      // Naviguer vers la messagerie avec l'ID du vendeur
      context.push('/messages/conversation/${product.userId}?productId=${product.id}');
    } else {
      // Afficher un message si pas de vendeur disponible (cas très rare)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de contacter le vendeur pour le moment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _callSeller(BuildContext context, Product product) async {
    // Utiliser en priorité le phone du produit, sinon celui du seller
    final phone = product.phone ?? product.seller?.phone;
    
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de téléphone non disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Nettoyer le numéro de téléphone et le copier dans le presse-papiers
      final cleanPhone = phone.replaceAll(RegExp(r'[^\+\d]'), '');
      await Clipboard.setData(ClipboardData(text: cleanPhone));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Numéro copié: $cleanPhone\nVous pouvez maintenant l\'utiliser pour appeler'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la copie: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 