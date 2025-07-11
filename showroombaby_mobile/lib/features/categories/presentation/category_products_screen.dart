import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryProductsScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName.isNotEmpty ? categoryName : 'Catégorie $categoryId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 100,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 16),
            Text(
              categoryName.isNotEmpty ? categoryName : 'Catégorie $categoryId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $categoryId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🚧 En cours de développement 🚧',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/categories'),
              child: const Text('Voir toutes les catégories'),
            ),
          ],
        ),
      ),
    );
  }
} 