<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Mettre à jour tous les utilisateurs existants
        DB::table('users')->whereNull('name')->update(['name' => '']);
        DB::table('users')->whereNull('firstName')->update(['firstName' => '']);
        DB::table('users')->whereNull('lastName')->update(['lastName' => '']);
        DB::table('users')->whereNull('phone')->update(['phone' => '']);
        DB::table('users')->whereNull('street')->update(['street' => '']);
        DB::table('users')->whereNull('city')->update(['city' => '']);
        DB::table('users')->whereNull('zipCode')->update(['zipCode' => '']);
        DB::table('users')->whereNull('country')->update(['country' => '']);
        DB::table('users')->whereNull('latitude')->update(['latitude' => 0]);
        DB::table('users')->whereNull('longitude')->update(['longitude' => 0]);
        DB::table('users')->whereNull('rating')->update(['rating' => 0.0]);

        // Mettre à jour le nom d'utilisateur si vide ou null en utilisant l'email
        DB::statement("UPDATE users SET name = username WHERE (name IS NULL OR name = '') AND username IS NOT NULL");
        DB::statement("UPDATE users SET name = email WHERE (name IS NULL OR name = '') AND email IS NOT NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Il n'est pas possible de restaurer les valeurs NULL précédentes
    }
};
