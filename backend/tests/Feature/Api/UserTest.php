<?php

namespace Tests\Feature\API;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UserTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => Hash::make('password123'),
            'username' => 'testuser'
        ]);
    }

    /**
     * Test qu'un utilisateur authentifié peut voir son profil.
     */
    public function test_user_can_view_profile(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->getJson('/api/users/profile');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'id',
                'email',
                'username',
                'role'
            ])
            ->assertJson([
                'email' => 'test@example.com',
                'username' => 'testuser'
            ]);
    }

    /**
     * Test qu'un utilisateur authentifié peut mettre à jour son profil.
     */
    public function test_user_can_update_profile(): void
    {
        Sanctum::actingAs($this->user);
        
        Storage::fake('public');

        $updateData = [
            'firstName' => 'John',
            'lastName' => 'Doe',
            'username' => 'johndoe'
        ];

        $response = $this->putJson('/api/users/profile', $updateData);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'id',
                'email',
                'username'
            ])
            ->assertJson([
                'username' => 'johndoe'
            ]);
    }

    /**
     * Test qu'un utilisateur authentifié peut changer son mot de passe.
     */
    public function test_user_can_change_password(): void
    {
        Sanctum::actingAs($this->user);

        $passwordData = [
            'oldPassword' => 'password123',
            'newPassword' => 'newpassword123',
            'newPassword_confirmation' => 'newpassword123'
        ];

        $response = $this->postJson('/api/users/change-password', $passwordData);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Mot de passe modifié avec succès'
            ]);

        // Vérifier que le nouveau mot de passe fonctionne
        $this->assertTrue(Hash::check('newpassword123', User::find($this->user->id)->password));
    }

    /**
     * Test qu'un utilisateur ne peut pas changer son mot de passe avec un ancien mot de passe incorrect.
     */
    public function test_user_cannot_change_password_with_incorrect_old_password(): void
    {
        Sanctum::actingAs($this->user);

        $passwordData = [
            'oldPassword' => 'wrongpassword',
            'newPassword' => 'newpassword123',
            'newPassword_confirmation' => 'newpassword123'
        ];

        $response = $this->postJson('/api/users/change-password', $passwordData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['oldPassword']);
    }

    /**
     * Test qu'un utilisateur authentifié peut supprimer son compte.
     */
    public function test_user_can_delete_account(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->deleteJson('/api/users/account');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Compte supprimé avec succès'
            ]);

        $this->assertDatabaseMissing('users', ['id' => $this->user->id]);
    }
}
