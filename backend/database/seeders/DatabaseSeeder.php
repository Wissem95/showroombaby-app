<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Product;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Créer un utilisateur de test
        $user = User::firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'password' => bcrypt('password'),
                'username' => 'testuser',
                'role' => 'USER',
            ]
        );

        // Créer des catégories
        $categories = [
            [
                'name' => 'Vêtements',
                'subcategories' => [
                    ['name' => 'Vêtements bébé (0-24 mois)'],
                    ['name' => 'Vêtements enfant (2-16 ans)']
                ]
            ],
            [
                'name' => 'Jouets',
                'subcategories' => [
                    ['name' => 'Jouets premier âge'],
                    ['name' => 'Jouets éducatifs']
                ]
            ],
            [
                'name' => 'Équipement',
                'subcategories' => [
                    ['name' => 'Poussettes'],
                    ['name' => 'Sièges auto']
                ]
            ],
        ];

        foreach ($categories as $categoryData) {
            $category = Category::firstOrCreate(
                ['name' => $categoryData['name']],
                ['slug' => Str::slug($categoryData['name'])]
            );

            // Créer les sous-catégories
            if (isset($categoryData['subcategories'])) {
                foreach ($categoryData['subcategories'] as $subcategoryData) {
                    Category::firstOrCreate(
                        ['name' => $subcategoryData['name']],
                        [
                            'slug' => Str::slug($subcategoryData['name']),
                            'parent_id' => $category->id
                        ]
                    );
                }
            }
        }

        // Récupérer toutes les catégories
        $allCategories = Category::all();

        // Créer quelques produits
        $products = [
            [
                'title' => 'Poussette bébé premium',
                'description' => 'Poussette légère et pratique pour bébé, idéale pour les sorties en ville.',
                'price' => 199.99,
                'condition' => 'LIKE_NEW',
                'category_id' => $allCategories->where('name', 'Poussettes')->first()->id ?? $allCategories->first()->id,
            ],
            [
                'title' => 'Lot de vêtements bébé 3-6 mois',
                'description' => 'Lot de 5 bodies et 3 pyjamas pour bébé, taille 3-6 mois, très bon état.',
                'price' => 25.50,
                'condition' => 'GOOD',
                'category_id' => $allCategories->where('name', 'Vêtements bébé (0-24 mois)')->first()->id ?? $allCategories->first()->id,
            ],
            [
                'title' => 'Siège auto groupe 1/2/3',
                'description' => 'Siège auto évolutif pour enfant de 9 mois à 12 ans, normes européennes.',
                'price' => 89.90,
                'condition' => 'GOOD',
                'category_id' => $allCategories->where('name', 'Sièges auto')->first()->id ?? $allCategories->first()->id,
            ],
        ];

        foreach ($products as $productData) {
            Product::firstOrCreate(
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
