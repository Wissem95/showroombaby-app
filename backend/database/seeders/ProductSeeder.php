<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use App\Models\ProductImage;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Créer un utilisateur si aucun n'existe
        $user = User::first();
        if (!$user) {
            $user = User::create([
                'name' => 'Admin',
                'email' => 'admin@showroombaby.com',
                'password' => bcrypt('password'),
                'username' => 'admin',
                'role' => 'ADMIN',
            ]);
        }

        // Créer les catégories
        $categories = [
            'Vêtements et accessoires',
            'Jeux et jouets',
            'Poussettes et transport',
            'Mobilier',
            'Puériculture',
            'Livres et activités',
            'Décoration',
            'Sécurité',
            'Alimentation',
            'Santé et hygiène',
        ];

        foreach ($categories as $categoryName) {
            Category::firstOrCreate(
                ['name' => $categoryName],
                ['description' => 'Catégorie de produits pour bébé et enfant']
            );
        }

        // Récupérer les catégories existantes
        $categories = Category::all();

        // Liste des produits à créer
        $products = [
            [
                'title' => 'Poussette tout-terrain 3 roues',
                'description' => 'Poussette tout-terrain à 3 roues, idéale pour les balades en forêt ou en ville. Très confortable pour bébé avec suspension et amortisseurs. Pliage facile d\'une seule main.',
                'price' => 349.99,
                'condition' => 'LIKE_NEW',
                'category_id' => 1, // Poussette
            ],
            [
                'title' => 'Lot de vêtements bébé fille 6-12 mois',
                'description' => 'Lot de vêtements bébé fille 6-12 mois en excellent état. Contient 5 bodies, 3 pyjamas, 2 robes et 4 pantalons. Marques diverses (Petit Bateau, H&M, Kiabi).',
                'price' => 45.00,
                'condition' => 'GOOD',
                'category_id' => 4, // Chaussure / Vêtements
            ],
            [
                'title' => 'Siège auto pivotant groupe 0+/1',
                'description' => 'Siège auto pivotant groupe 0+/1 (de la naissance à 18kg). Rotation à 360° pour installation dos/face route. Système Isofix. Utilisé 6 mois, comme neuf.',
                'price' => 189.90,
                'condition' => 'LIKE_NEW',
                'category_id' => 2, // Sièges auto
            ],
            [
                'title' => 'Lit à barreaux évolutif en bois',
                'description' => 'Lit à barreaux évolutif en bois de hêtre massif. Se transforme en lit d\'enfant. Sommier réglable en hauteur. Dimensions: 70x140cm. Sans matelas.',
                'price' => 120.00,
                'condition' => 'GOOD',
                'category_id' => 3, // Chambre
            ],
            [
                'title' => 'Tapis d\'éveil avec arches d\'activités',
                'description' => 'Tapis d\'éveil sensoriel avec arches d\'activités et jouets suspendus. Musique et lumières. Lavable en machine. Utilisé 4 mois, parfait état.',
                'price' => 29.90,
                'condition' => 'GOOD',
                'category_id' => 5, // Jeux / Éveil
            ],
            [
                'title' => 'Baignoire bébé avec transat intégré',
                'description' => 'Baignoire bébé ergonomique avec transat intégré et système anti-dérapant. Support de douche inclus. Bouchon de vidange. Très pratique et sécurisante.',
                'price' => 25.00,
                'condition' => 'GOOD',
                'category_id' => 7, // Toilette
            ],
            [
                'title' => 'Stérilisateur électrique 6 biberons',
                'description' => 'Stérilisateur électrique à vapeur pour 6 biberons. Cycle de stérilisation en 6 minutes. Accessoires inclus. Marque Philips Avent.',
                'price' => 40.00,
                'condition' => 'LIKE_NEW',
                'category_id' => 8, // Repas
            ],
            [
                'title' => 'Mobile musical projection étoiles',
                'description' => 'Mobile musical avec projection d\'étoiles au plafond. 30 mélodies différentes. Télécommande incluse. Parfait pour aider bébé à s\'endormir.',
                'price' => 35.50,
                'condition' => 'LIKE_NEW',
                'category_id' => 3, // Chambre
            ],
            [
                'title' => 'Chaise haute évolutive en bois',
                'description' => 'Chaise haute évolutive en bois qui grandit avec l\'enfant. Utilisable de 6 mois à 10 ans. Tablette amovible, coussin et harnais inclus.',
                'price' => 79.00,
                'condition' => 'GOOD',
                'category_id' => 8, // Repas
            ],
            [
                'title' => 'Lot de 10 livres pour bébé',
                'description' => 'Lot de 10 livres cartonnés pour bébé. Thèmes variés: animaux, couleurs, comptines, etc. État impeccable, sans traces ni déchirures.',
                'price' => 22.00,
                'condition' => 'LIKE_NEW',
                'category_id' => 6, // Livre / Dvd
            ],
        ];

        // Créer les produits
        foreach ($products as $productData) {
            $product = Product::firstOrCreate(
                ['title' => $productData['title']],
                [
                    'description' => $productData['description'],
                    'price' => $productData['price'],
                    'condition' => $productData['condition'],
                    'status' => 'PUBLISHED',
                    'category_id' => $productData['category_id'],
                    'user_id' => $user->id,
                    'city' => 'Paris',
                    'zipCode' => '75000',
                    'phone' => '0612345678',
                    'hide_phone' => false,
                    'latitude' => 48.8566,
                    'longitude' => 2.3522,
                    'address' => '1 Rue de Paris',
                    'view_count' => rand(10, 100)
                ]
            );
        }
    }
}
