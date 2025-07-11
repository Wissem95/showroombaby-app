<?php

namespace Tests\Feature\API;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Category;
use App\Models\Favorite;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Laravel\Sanctum\Sanctum;

class FavoriteTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    private User $user;
    private Product $product;

    protected function setUp(): void
    {
        parent::setUp();

        // Créer un utilisateur et un produit pour les tests
        $this->user = User::factory()->create();
        $category = Category::factory()->create();
        $this->product = Product::factory()->create([
            'user_id' => User::factory()->create()->id,
            'category_id' => $category->id
        ]);
    }

    public function test_user_can_add_favorite(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson("/api/favorites/{$this->product->id}");

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'user_id',
                    'product_id',
                    'created_at',
                    'updated_at'
                ]
            ]);

        $this->assertDatabaseHas('favorites', [
            'user_id' => $this->user->id,
            'product_id' => $this->product->id
        ]);
    }

    public function test_user_cannot_add_duplicate_favorite(): void
    {
        Sanctum::actingAs($this->user);

        // Ajouter le favori une première fois
        $this->postJson("/api/favorites/{$this->product->id}");

        // Essayer d'ajouter le même favori une deuxième fois
        $response = $this->postJson("/api/favorites/{$this->product->id}");

        $response->assertStatus(422);
    }

    public function test_user_can_list_favorites(): void
    {
        Sanctum::actingAs($this->user);

        // Créer quelques favoris
        Favorite::factory()->count(3)->create([
            'user_id' => $this->user->id
        ]);

        $response = $this->getJson('/api/favorites');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'user_id',
                        'product_id',
                        'created_at',
                        'updated_at',
                        'product' => [
                            'id',
                            'title',
                            'price'
                        ]
                    ]
                ]
            ]);
    }

    public function test_user_can_remove_favorite(): void
    {
        Sanctum::actingAs($this->user);

        // Ajouter un favori
        $favorite = Favorite::factory()->create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id
        ]);

        $response = $this->deleteJson("/api/favorites/{$this->product->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('favorites', ['id' => $favorite->id]);
    }

    public function test_user_cannot_remove_others_favorite(): void
    {
        $otherUser = User::factory()->create();
        Sanctum::actingAs($otherUser);

        // Créer un favori pour l'utilisateur principal
        $favorite = Favorite::factory()->create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id
        ]);

        $response = $this->deleteJson("/api/favorites/{$this->product->id}");

        $response->assertStatus(404);
        $this->assertDatabaseHas('favorites', ['id' => $favorite->id]);
    }

    public function test_user_can_view_favorite_details(): void
    {
        Sanctum::actingAs($this->user);

        $favorite = Favorite::factory()->create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id
        ]);

        $response = $this->getJson("/api/favorites/{$favorite->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'user_id',
                    'product_id',
                    'created_at',
                    'updated_at',
                    'product' => [
                        'id',
                        'title',
                        'price',
                        'description'
                    ]
                ]
            ]);
    }

    public function test_user_cannot_view_others_favorite_details(): void
    {
        $otherUser = User::factory()->create();
        Sanctum::actingAs($otherUser);

        $favorite = Favorite::factory()->create([
            'user_id' => $this->user->id,
            'product_id' => $this->product->id
        ]);

        $response = $this->getJson("/api/favorites/{$favorite->id}");

        $response->assertStatus(403);
    }
}
