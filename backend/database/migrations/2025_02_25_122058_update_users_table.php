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
        Schema::table('users', function (Blueprint $table) {
            $table->string('username')->nullable()->unique()->after('name');
            $table->string('firstName')->nullable()->after('username');
            $table->string('lastName')->nullable()->after('firstName');
            $table->string('avatar')->nullable()->after('lastName');
            $table->enum('role', ['USER', 'ADMIN'])->default('USER')->after('avatar');
            $table->boolean('isEmailVerified')->default(false)->after('role');
            $table->float('rating')->default(0)->after('isEmailVerified');

            // Adresse
            $table->string('street')->nullable()->after('rating');
            $table->string('city')->nullable()->after('street');
            $table->string('zipCode')->nullable()->after('city');
            $table->string('country')->nullable()->after('zipCode');

            // Information de géolocalisation
            $table->float('latitude')->nullable()->after('country');
            $table->float('longitude')->nullable()->after('latitude');
            $table->string('phone')->nullable()->after('longitude');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'username', 'firstName', 'lastName', 'avatar', 'role',
                'isEmailVerified', 'rating', 'street', 'city', 'zipCode',
                'country', 'latitude', 'longitude', 'phone'
            ]);
        });
    }
};
