<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiTest extends TestCase
{
    /**
     * Test de base pour vérifier que l'endpoint /api/test fonctionne.
     */
    public function test_the_api_test_endpoint_returns_success_message()
    {
        $response = $this->get('/api/test');

        $response->assertStatus(200)
                ->assertJson([
                    'message' => 'L\'API fonctionne correctement',
                    'status' => 'success'
                ]);
    }

    /**
     * Test de base pour vérifier que la route racine fonctionne.
     */
    public function test_the_welcome_endpoint_returns_correct_message()
    {
        $response = $this->get('/');

        $response->assertStatus(200)
                ->assertJson([
                    'message' => 'Bienvenue sur l\'API ShowroomBaby'
                ]);
    }
}
