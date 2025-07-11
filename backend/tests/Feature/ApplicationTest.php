<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use App\Models\Favorite;
use App\Models\Report;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Illuminate\Support\Facades\Hash;

class ApplicationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test du flux complet d'utilisation de l'application en utilisant directement les modèles.
     * Ce test vérifie l'ensemble des fonctionnalités principales :
     * - Création d'un utilisateur
     * - Création d'une catégorie
     * - Création d'un produit
     * - Ajout d'un produit aux favoris
     * - Signalement d'un produit
     */
    public function test_complete_application_flow(): void
    {
        // 1. Création d'un utilisateur admin
        $admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => Hash::make('password123'),
            'role' => 'ADMIN'
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'admin@example.com',
            'role' => 'ADMIN'
        ]);

        // 2. Création d'une catégorie
        $category = Category::create([
            'name' => 'Test Category',
            'description' => 'A test category'
        ]);

        $this->assertDatabaseHas('categories', [
            'name' => 'Test Category'
        ]);

        // 3. Création d'un produit
        $product = Product::create([
            'title' => 'Test Product',
            'description' => 'A test product',
            'price' => 99.99,
            'category_id' => $category->id,
            'user_id' => $admin->id,
            'condition' => 'NEW',
            'location' => 'Paris'
        ]);

        $this->assertDatabaseHas('products', [
            'title' => 'Test Product',
            'user_id' => $admin->id
        ]);

        // 4. Création d'un second utilisateur
        $user = User::create([
            'name' => 'Regular User',
            'email' => 'user@example.com',
            'password' => Hash::make('password123')
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'user@example.com'
        ]);

        // 5. Ajout du produit aux favoris
        $favorite = Favorite::create([
            'user_id' => $user->id,
            'product_id' => $product->id
        ]);

        $this->assertDatabaseHas('favorites', [
            'user_id' => $user->id,
            'product_id' => $product->id
        ]);

        // 6. Signalement du produit
        $report = Report::create([
            'reporter_id' => $user->id,
            'product_id' => $product->id,
            'reason' => 'inappropriate',
            'description' => 'This product contains inappropriate content',
            'status' => 'pending'
        ]);

        $this->assertDatabaseHas('reports', [
            'reporter_id' => $user->id,
            'product_id' => $product->id,
            'status' => 'pending'
        ]);

        // 7. Traitement du signalement par l'admin
        $report->status = 'resolved';
        $report->moderation_note = 'Reviewed and resolved';
        $report->save();

        $this->assertDatabaseHas('reports', [
            'id' => $report->id,
            'status' => 'resolved',
            'moderation_note' => 'Reviewed and resolved'
        ]);
    }
}
