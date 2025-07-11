# 🛍️ Interface Produits - ShowroomBaby

## Écrans d'interface utilisateur

### 1. Home Screen (features/home/presentation/home_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final productsAsync = ref.watch(productListProvider);
    final trendingAsync = ref.watch(trendingProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShowroomBaby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => context.push('/messages'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productListProvider);
          ref.invalidate(trendingProductsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salutation
              if (user != null)
                Text(
                  'Bonjour ${user.username} !',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 16),

              // Barre de recherche
              _buildSearchBar(context),

              const SizedBox(height: 24),

              // Produits tendance
              _buildTrendingSection(context, ref, trendingAsync),

              const SizedBox(height: 24),

              // Tous les produits
              _buildAllProductsSection(context, ref, productsAsync),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Rechercher des produits...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onTap: () => context.push('/search'),
        readOnly: true,
      ),
    );
  }

  Widget _buildTrendingSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> trendingAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tendances',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/trending'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: trendingAsync.when(
            data: (products) => ListView.builder(
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
                    onFavorite: () => _toggleFavorite(ref, product),
                  ),
                );
              },
            ),
            loading: () => const LoadingWidget(),
            error: (error, stack) => CustomErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(trendingProductsProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllProductsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> productsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tous les produits',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        productsAsync.when(
          data: (products) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => context.push('/product/${product.id}'),
                onFavorite: () => _toggleFavorite(ref, product),
              );
            },
          ),
          loading: () => const LoadingWidget(message: 'Chargement des produits...'),
          error: (error, stack) => CustomErrorWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(productListProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoris',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
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
    );
  }

  void _toggleFavorite(WidgetRef ref, Product product) {
    // Implémentation du toggle favori
    // À connecter avec le service des favoris
  }
}
```

### 2. Product Details Screen (features/products/presentation/product_details_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/product.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/custom_button.dart';
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
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageCarousel(product.images),
          ),
          actions: [
            IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: product.isFavorite ? AppColors.favorite : null,
              ),
              onPressed: () => _toggleFavorite(ref, product),
            ),
            PopupMenuButton(
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
                _buildProductDetails(context, product),

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
          '${product.price.toStringAsFixed(2)} €',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.price,
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
          backgroundImage: product.seller?.avatar != null
              ? NetworkImage(product.seller!.avatar!)
              : null,
          child: product.seller?.avatar == null
              ? Text(product.seller?.username.substring(0, 1).toUpperCase() ?? '?')
              : null,
        ),
        title: Text(product.seller?.username ?? 'Vendeur'),
        subtitle: Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text('${product.seller?.rating?.toStringAsFixed(1) ?? 'N/A'}'),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(product.city ?? 'Non spécifié'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Naviguer vers le profil du vendeur
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

  Widget _buildProductDetails(BuildContext context, Product product) {
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
            text: 'Appeler',
            icon: const Icon(Icons.phone, size: 20),
            isOutlined: true,
            onPressed: product.hidePhone ? null : () => _callSeller(product),
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

  void _toggleFavorite(WidgetRef ref, Product product) {
    // Implémentation toggle favori
  }

  void _handleMenuAction(BuildContext context, String action, Product product) {
    switch (action) {
      case 'share':
        // Implémentation partage
        break;
      case 'report':
        // Implémentation signalement
        break;
    }
  }

  void _contactSeller(BuildContext context, Product product) {
    // Naviguer vers la messagerie
    context.push('/messages/conversation/${product.seller?.id}?productId=${product.id}');
  }

  void _callSeller(Product product) {
    // Ouvrir l'application téléphone
  }
}
```

Ces écrans fournissent une interface complète pour visualiser et interagir avec les produits !
