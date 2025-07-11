<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Report>
 */
class ReportFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'product_id' => \App\Models\Product::factory(),
            'reporter_id' => \App\Models\User::factory(),
            'reason' => $this->faker->randomElement(['inappropriate', 'fake', 'offensive', 'spam', 'other']),
            'description' => $this->faker->paragraph(),
            'status' => 'pending',
            'moderation_note' => null
        ];
    }
}
