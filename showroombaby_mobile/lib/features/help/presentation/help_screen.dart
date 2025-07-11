import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpSection(
            'Questions fréquentes',
            [
              _buildHelpTile(
                'Comment vendre un produit ?',
                'Appuyez sur le bouton + pour ajouter un nouveau produit...',
              ),
              _buildHelpTile(
                'Comment contacter un vendeur ?',
                'Depuis la page produit, appuyez sur "Contacter"...',
              ),
              _buildHelpTile(
                'Comment ajouter aux favoris ?',
                'Appuyez sur l\'icône cœur sur la page produit...',
              ),
            ],
          ),
          
          _buildHelpSection(
            'Compte et sécurité',
            [
              _buildHelpTile(
                'Modifier mon profil',
                'Allez dans Profil > Modifier le profil...',
              ),
              _buildHelpTile(
                'Signaler un problème',
                'Utilisez le bouton "Signaler" sur les pages produits...',
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.contact_support,
                    size: 48,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Besoin d\'aide ?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contactez notre équipe support',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showContactSupport(context),
                    child: const Text('Contacter le support'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              '🚧 En cours de développement 🚧',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildHelpTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _showContactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en cours de développement')),
    );
  }
} 