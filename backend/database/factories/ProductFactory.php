<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        return [
            'title' => $this->faker->sentence(3),
            'description' => $this->faker->paragraph(),
            'price' => $this->faker->randomFloat(2, 10, 1000),
            'condition' => $this->faker->randomElement(['NEW', 'LIKE_NEW', 'GOOD', 'FAIR']),
            'status' => 'PUBLISHED',
            'user_id' => User::factory(),
            'category_id' => Category::factory(),
            'view_count' => $this->faker->numberBetween(0, 1000),
            'latitude' => $this->faker->latitude(43.0, 49.0),
            'longitude' => $this->faker->longitude(-1.0, 8.0),
            'address' => $this->faker->streetAddress(),
            'city' => $this->faker->city(),
            'zipCode' => $this->faker->postcode(),
            'phone' => $this->faker->phoneNumber(),
        ];
    }
}
