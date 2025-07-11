<?php 

use Illuminate\Support\Facades\Route;

Route::get("/", function() { 
    return ["message" => "Bienvenue sur l'API ShowroomBaby"]; 
});
