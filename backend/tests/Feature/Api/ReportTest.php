<?php

namespace Tests\Feature\API;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Category;
use App\Models\Report;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Laravel\Sanctum\Sanctum;

class ReportTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    private User $user;
    private User $adminUser;
    private Product $product;

    protected function setUp(): void
    {
        parent::setUp();

        // Créer un utilisateur standard
        $this->user = User::factory()->create([
            'role' => 'USER'
        ]);

        // Créer un utilisateur administrateur
        $this->adminUser = User::factory()->create([
            'role' => 'ADMIN'
        ]);

        // Créer un produit pour les tests
        $category = Category::factory()->create();
        $this->product = Product::factory()->create([
            'user_id' => $this->user->id,
            'category_id' => $category->id
        ]);
    }

    /**
     * Test qu'un utilisateur peut créer un signalement.
     */
    public function test_user_can_create_report(): void
    {
        Sanctum::actingAs($this->user);

        $reportData = [
            'productId' => $this->product->id,
            'reason' => 'offensive',
            'description' => $this->faker->paragraph
        ];

        $response = $this->postJson('/api/reports', $reportData);

        $response->assertStatus(201);

        $this->assertDatabaseHas('reports', [
            'product_id' => $this->product->id,
            'reporter_id' => $this->user->id,
            'reason' => 'offensive'
        ]);
    }

    /**
     * Test qu'un utilisateur ne peut pas signaler le même produit deux fois.
     */
    public function test_user_cannot_report_same_product_twice(): void
    {
        Sanctum::actingAs($this->user);

        // Premier signalement
        Report::factory()->create([
            'product_id' => $this->product->id,
            'reporter_id' => $this->user->id,
            'reason' => 'inappropriate'
        ]);

        // Tentative de second signalement
        $reportData = [
            'productId' => $this->product->id,
            'reason' => 'offensive',
            'description' => $this->faker->paragraph
        ];

        $response = $this->postJson('/api/reports', $reportData);

        $response->assertStatus(400)
            ->assertJson([
                'message' => 'Vous avez déjà signalé ce produit'
            ]);
    }
}
