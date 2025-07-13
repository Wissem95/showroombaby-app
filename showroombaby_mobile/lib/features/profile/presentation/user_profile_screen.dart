import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/models/product.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../app/theme/app_colors.dart';

class UserProfileScreen extends ConsumerWidget {
  final int userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));
    final userProductsAsync = ref.watch(userProductsByIdProvider(userId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: userAsync.when(
        data: (user) => _buildUserProfile(context, ref, user, userProductsAsync),
        loading: () => const Scaffold(
          appBar: null,
          body: LoadingWidget(),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Profil utilisateur'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: CustomErrorWidget(
            message: 'Impossible de charger le profil utilisateur',
            onRetry: () => ref.refresh(userProfileProvider(userId)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    WidgetRef ref,
    User user,
    AsyncValue<List<Product>> userProductsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // AppBar avec informations utilisateur
        _buildSliverAppBar(context, user),
        
        // Informations détaillées du vendeur
        SliverToBoxAdapter(
          child: _buildUserInfo(context, user),
        ),
        
        // Section des produits
        SliverToBoxAdapter(
          child: _buildProductsSection(context, userProductsAsync),
        ),
        
        // Liste des produits
        userProductsAsync.when(
          data: (products) => _buildProductsList(context, products),
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: LoadingWidget(),
            ),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CustomErrorWidget(
                message: 'Impossible de charger les produits',
                                 onRetry: () => ref.refresh(userProductsByIdProvider(userId)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _getUserDisplayName(user),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.message, color: Colors.white),
          onPressed: () => context.push('/messages/conversation/$userId'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Espace pour la barre d'état
                // Avatar utilisateur
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: user.avatar != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.avatar!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => _buildAvatarFallback(user),
                          ),
                        )
                      : _buildAvatarFallback(user),
                ),
                const SizedBox(height: 12),
                // Nom utilisateur
                Text(
                  _getUserDisplayName(user),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      user.rating != null 
                          ? user.rating!.toStringAsFixed(1) 
                          : '4.5',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(User user) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(user),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section informations de base
          _buildInfoSection('Informations', [
            if (user.email.isNotEmpty) _buildInfoRow(Icons.email, 'Email', user.email),
            if (user.phone != null && user.phone!.isNotEmpty) 
              _buildInfoRow(Icons.phone, 'Téléphone', user.phone!),
            if (user.city != null && user.city!.isNotEmpty) 
              _buildInfoRow(Icons.location_on, 'Ville', user.city!),
            if (user.createdAt != null) 
              _buildInfoRow(Icons.calendar_today, 'Membre depuis', _formatDate(user.createdAt!)),
          ]),
          
          const SizedBox(height: 20),
          
          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Envoyer un message',
              icon: const Icon(Icons.message, size: 20),
              onPressed: () => context.push('/messages/conversation/$userId'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context, AsyncValue<List<Product>> userProductsAsync) {
    final productCount = userProductsAsync.when(
      data: (products) => products.length,
      loading: () => 0,
      error: (error, stack) => 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            'Annonces publiées',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              productCount.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune annonce publiée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cet utilisateur n\'a pas encore publié d\'annonces',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return _buildProductCard(context, product);
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 40),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
              ),
            ),
            
            // Informations du produit
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Prix
                    Text(
                      product.price != null 
                          ? '${product.price!.toStringAsFixed(0)}€'
                          : 'Prix à négocier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: product.price != null ? AppColors.primary : Colors.grey[600],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Localisation
                    if (product.city != null)
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.city!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserDisplayName(User user) {
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!;
    }
    
    if (user.firstName != null || user.lastName != null) {
      final firstName = user.firstName ?? '';
      final lastName = user.lastName ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }
    
    if (user.username.isNotEmpty) {
      return user.username;
    }
    
    return 'Utilisateur ${user.id}';
  }

  String _getInitials(User user) {
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!.substring(0, 1).toUpperCase();
    }
    
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      return user.firstName!.substring(0, 1).toUpperCase();
    }
    
    if (user.username.isNotEmpty) {
      return user.username.substring(0, 1).toUpperCase();
    }
    
    return 'U${user.id}'.substring(0, 2).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }
} 