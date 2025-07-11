<?php

namespace Tests\Feature\API;

use Tests\TestCase;
use App\Models\User;
use App\Models\Category;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Laravel\Sanctum\Sanctum;

class CategoryTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    private User $admin;
    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        // Créer un admin et un utilisateur normal
        $this->admin = User::factory()->create(['role' => 'ADMIN']);
        $this->user = User::factory()->create(['role' => 'USER']);
    }

    public function test_anyone_can_list_categories(): void
    {
        Category::factory()->count(5)->create();

        $response = $this->getJson('/api/categories');

        $response->assertStatus(200);
    }

    public function test_admin_can_create_category(): void
    {
        Sanctum::actingAs($this->admin);

        $categoryData = [
            'name' => $this->faker->word,
            'description' => $this->faker->sentence
        ];

        $response = $this->postJson('/api/categories', $categoryData);

        $response->assertStatus(201);

        $this->assertDatabaseHas('categories', [
            'name' => $categoryData['name'],
            'description' => $categoryData['description']
        ]);
    }

    public function test_non_admin_cannot_create_category(): void
    {
        Sanctum::actingAs($this->user);

        $categoryData = [
            'name' => $this->faker->word,
            'description' => $this->faker->sentence
        ];

        $response = $this->postJson('/api/categories', $categoryData);

        $response->assertStatus(403);
    }

    public function test_admin_can_update_category(): void
    {
        Sanctum::actingAs($this->admin);

        $category = Category::factory()->create();
        $updateData = [
            'name' => 'Nouveau nom',
            'description' => 'Nouvelle description'
        ];

        $response = $this->putJson("/api/categories/{$category->id}", $updateData);

        $response->assertStatus(200);

        $this->assertDatabaseHas('categories', [
            'id' => $category->id,
            'name' => 'Nouveau nom',
            'description' => 'Nouvelle description'
        ]);
    }

    public function test_non_admin_cannot_update_category(): void
    {
        Sanctum::actingAs($this->user);

        $category = Category::factory()->create();
        $updateData = [
            'name' => 'Nouveau nom',
            'description' => 'Nouvelle description'
        ];

        $response = $this->putJson("/api/categories/{$category->id}", $updateData);

        $response->assertStatus(403);
    }

    public function test_admin_can_delete_category(): void
    {
        Sanctum::actingAs($this->admin);

        $category = Category::factory()->create();

        $response = $this->deleteJson("/api/categories/{$category->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('categories', ['id' => $category->id]);
    }

    public function test_non_admin_cannot_delete_category(): void
    {
        Sanctum::actingAs($this->user);

        $category = Category::factory()->create();

        $response = $this->deleteJson("/api/categories/{$category->id}");

        $response->assertStatus(403);
        $this->assertDatabaseHas('categories', ['id' => $category->id]);
    }
}
