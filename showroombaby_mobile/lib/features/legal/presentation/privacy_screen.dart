import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
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
              'Politique de confidentialité',
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
              '1. Collecte des données',
              'Nous collectons les informations que vous nous fournissez lors de votre inscription...',
            ),
            
            _buildSection(
              '2. Utilisation des données',
              'Vos données sont utilisées pour améliorer notre service et vous fournir une expérience personnalisée...',
            ),
            
            _buildSection(
              '3. Partage des données',
              'Nous ne vendons jamais vos données personnelles à des tiers...',
            ),
            
            _buildSection(
              '4. Sécurité',
              'Nous mettons en place des mesures de sécurité appropriées pour protéger vos données...',
            ),
            
            _buildSection(
              '5. Vos droits',
              'Vous avez le droit d\'accéder, de modifier ou de supprimer vos données personnelles...',
            ),
            
            _buildSection(
              '6. Cookies',
              'Nous utilisons des cookies pour améliorer votre expérience utilisateur...',
            ),
            
            _buildSection(
              '7. Contact',
              'Pour toute question concernant cette politique, contactez-nous à privacy@showroombaby.com',
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