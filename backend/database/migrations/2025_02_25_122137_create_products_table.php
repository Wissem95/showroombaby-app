<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->decimal('price', 10, 2);
            $table->enum('condition', ['NEW', 'LIKE_NEW', 'GOOD', 'FAIR'])->default('NEW');
            $table->enum('status', ['DRAFT', 'PUBLISHED', 'SOLD', 'ARCHIVED'])->default('PUBLISHED');

            // Géolocalisation
            $table->float('latitude')->nullable();
            $table->float('longitude')->nullable();
            $table->string('address')->nullable();
            $table->string('city')->nullable();
            $table->string('zipCode')->nullable();
            $table->string('phone')->nullable();
            $table->boolean('hide_phone')->default(false);

            // Relations
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
