<?php

namespace Tests\Feature\API;

use Tests\TestCase;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;

class AuthTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    /**
     * Test l'inscription d'un nouvel utilisateur.
     */
    public function test_user_can_register()
    {
        $userData = [
            'email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'username' => 'testuser'
        ];

        $response = $this->postJson('/api/auth/register', $userData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'user' => [
                    'id',
                    'email',
                    'username'
                ],
                'access_token',
                'message'
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
            'username' => 'testuser'
        ]);
    }

    /**
     * Test qu'un utilisateur ne peut pas s'inscrire avec un email déjà utilisé.
     */
    public function test_user_cannot_register_with_existing_email()
    {
        User::factory()->create([
            'email' => 'test@example.com'
        ]);

        $userData = [
            'email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'username' => 'testuser2'
        ];

        $response = $this->postJson('/api/auth/register', $userData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * Test la connexion d'un utilisateur.
     */
    public function test_user_can_login()
    {
        $user = User::factory()->create([
            'email' => 'user@example.com',
            'password' => bcrypt('password123')
        ]);

        $loginData = [
            'email' => 'user@example.com',
            'password' => 'password123'
        ];

        $response = $this->postJson('/api/auth/login', $loginData);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'access_token',
                'message',
                'user' => [
                    'id',
                    'email',
                    'username'
                ]
            ]);
    }

    /**
     * Test qu'un utilisateur ne peut pas se connecter avec des identifiants invalides.
     */
    public function test_user_cannot_login_with_invalid_credentials()
    {
        $user = User::factory()->create([
            'email' => 'user@example.com',
            'password' => bcrypt('password123')
        ]);

        $loginData = [
            'email' => 'user@example.com',
            'password' => 'wrongpassword'
        ];

        $response = $this->postJson('/api/auth/login', $loginData);

        $response->assertStatus(401);
    }

    /**
     * Test la déconnexion d'un utilisateur.
     */
    public function test_user_can_logout()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Déconnexion réussie'
            ]);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
