import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions d\'utilisation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'Dernière mise à jour : ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              '1. Acceptation des conditions',
              'En utilisant ShowroomBaby, vous acceptez ces conditions d\'utilisation...',
            ),
            
            _buildSection(
              '2. Description du service',
              'ShowroomBaby est une marketplace dédiée aux articles de bébé d\'occasion...',
            ),
            
            _buildSection(
              '3. Compte utilisateur',
              'Vous devez créer un compte pour utiliser certaines fonctionnalités...',
            ),
            
            _buildSection(
              '4. Vente et achat',
              'Les transactions entre utilisateurs sont soumises aux règles suivantes...',
            ),
            
            _buildSection(
              '5. Contenu utilisateur',
              'Vous êtes responsable du contenu que vous publiez sur la plateforme...',
            ),
            
            _buildSection(
              '6. Règles de conduite',
              'Vous vous engagez à respecter les autres utilisateurs...',
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Text(
                '🚧 Document complet en cours de rédaction 🚧',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('J\'ai lu et compris'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 