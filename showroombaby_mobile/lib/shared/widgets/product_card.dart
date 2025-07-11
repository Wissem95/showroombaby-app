import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/product.dart';
import '../../app/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.showFavorite = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryImage = product.images.isNotEmpty
        ? product.images.firstWhere(
            (img) => img.isPrimary,
            orElse: () => product.images.first,
          )
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: primaryImage != null
                      ? CachedNetworkImage(
                          imageUrl: primaryImage.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
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
            ),

            // Contenu
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10), // Réduit de 12 à 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre et favori
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13, // Réduit de 14 à 13
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showFavorite && onFavorite != null)
                          InkWell(
                            onTap: onFavorite,
                            child: Icon(
                              product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.isFavorite
                                  ? AppColors.favorite
                                  : Colors.grey,
                              size: 16, // Réduit de 18 à 16
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 2), // Réduit de 3 à 2

                    // Prix
                    Text(
                      product.price != null 
                          ? '${product.price!.toStringAsFixed(2)} €'
                          : 'Prix à négocier',
                      style: TextStyle(
                        fontSize: 14, // Réduit de 15 à 14
                        fontWeight: FontWeight.bold,
                        color: product.price != null ? AppColors.price : Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 2), // Réduit de 3 à 2

                    // Localisation
                    if (product.city != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 11, // Réduit de 12 à 11
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              product.city!,
                              style: const TextStyle(
                                fontSize: 10, // Réduit de 11 à 10
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    // Utiliser un SizedBox plus petit
                    const SizedBox(height: 2),

                    // État
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5, // Réduit de 6 à 5
                        vertical: 1, // Réduit de 2 à 1
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(product.condition).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4), // Réduit de 6 à 4
                      ),
                      child: Text(
                        _getConditionText(product.condition),
                        style: TextStyle(
                          fontSize: 8, // Réduit de 9 à 8
                          color: _getConditionColor(product.condition),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Color _getConditionColor(ProductCondition condition) {
    switch (condition) {
      case ProductCondition.newCondition:
        return AppColors.success;
      case ProductCondition.likeNew:
        return AppColors.info;
      case ProductCondition.good:
        return AppColors.warning;
      case ProductCondition.fair:
        return Colors.orange;
    }
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
} 