<?php

namespace Tests\Feature\Api;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_get_notifications()
    {
        $user = User::factory()->create();

        // Créer quelques notifications
        Notification::create([
            'user_id' => $user->id,
            'type' => 'message',
            'title' => 'Nouveau message',
            'message' => 'Vous avez reçu un nouveau message',
            'status' => 'unread'
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/notifications');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data',
                'meta' => ['current_page', 'last_page', 'per_page', 'total']
            ]);
    }

    public function test_user_can_get_unread_notifications()
    {
        $user = User::factory()->create();

        // Créer notification lue
        Notification::create([
            'user_id' => $user->id,
            'type' => 'system',
            'title' => 'Notification lue',
            'message' => 'Cette notification est lue',
            'status' => 'read'
        ]);

        // Créer notification non lue
        Notification::create([
            'user_id' => $user->id,
            'type' => 'message',
            'title' => 'Notification non lue',
            'message' => 'Cette notification est non lue',
            'status' => 'unread'
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/notifications/unread');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    public function test_user_can_mark_notification_as_read()
    {
        $user = User::factory()->create();

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'message',
            'title' => 'Test notification',
            'message' => 'Notification à marquer comme lue',
            'status' => 'unread'
        ]);

        Sanctum::actingAs($user);

        $response = $this->postJson("/api/notifications/{$notification->id}/read");

        $response->assertStatus(200);

        $this->assertDatabaseHas('notifications', [
            'id' => $notification->id,
            'status' => 'read'
        ]);
    }

    public function test_user_can_mark_all_notifications_as_read()
    {
        $user = User::factory()->create();

        // Créer 3 notifications non lues
        for ($i = 0; $i < 3; $i++) {
            Notification::create([
                'user_id' => $user->id,
                'type' => 'message',
                'title' => "Notification $i",
                'message' => "Contenu de la notification $i",
                'status' => 'unread'
            ]);
        }

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/notifications/read/all');

        $response->assertStatus(200);

        $this->assertEquals(0,
            Notification::where('user_id', $user->id)
                ->where('status', 'unread')
                ->count()
        );
    }
}
