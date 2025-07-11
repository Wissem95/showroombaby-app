<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\MessageController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\FavoriteController;
use App\Http\Controllers\API\ReportController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Routes pour l'API ShowroomBaby
|
*/

// Test route
Route::get('/test', function () {
    return response()->json([
        'message' => 'L\'API fonctionne correctement',
        'status' => 'success'
    ]);
});

// Routes d'authentification
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->post('/auth/logout', [AuthController::class, 'logout']);
Route::middleware('auth:sanctum')->get('/auth/check', [AuthController::class, 'check']);

// Routes des produits
Route::prefix('products')->group(function () {
    Route::get('/', [ProductController::class, 'index']);
    Route::get('/trending', [ProductController::class, 'trending']);
    Route::get('/{id}', [ProductController::class, 'show']);
    Route::get('/{id}/similar', [ProductController::class, 'similar']);
    Route::get('/{id}/images', [ProductController::class, 'getImages']);

    // Routes protégées
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/', [ProductController::class, 'store']);
        Route::put('/{id}', [ProductController::class, 'update']);
        Route::delete('/{id}', [ProductController::class, 'destroy']);
    });
});

// Routes des catégories
Route::prefix('categories')->group(function () {
    Route::get('/', [CategoryController::class, 'index']);

    // Routes admin
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/', [CategoryController::class, 'store']);
        Route::put('/{id}', [CategoryController::class, 'update']);
        Route::delete('/{id}', [CategoryController::class, 'destroy']);
    });
});

// Routes des utilisateurs
Route::middleware('auth:sanctum')->prefix('users')->group(function () {
    Route::get('/profile', [UserController::class, 'profile']);
    Route::get('/profile/{id}', [UserController::class, 'showProfile']);
    Route::put('/profile', [UserController::class, 'updateProfile']);
    Route::post('/change-password', [UserController::class, 'changePassword']);
    Route::delete('/account', [UserController::class, 'deleteAccount']);
});

// Route publique pour récupérer les informations d'un utilisateur
Route::get('/users/{id}', [UserController::class, 'showProfile']);

// Routes des messages
Route::middleware('auth:sanctum')->prefix('messages')->group(function () {
    Route::post('/', [MessageController::class, 'store']);
    Route::get('/conversations', [MessageController::class, 'conversations']);
    Route::get('/conversations/archived', [MessageController::class, 'archivedConversations']);
    Route::get('/conversation/{userId}', [MessageController::class, 'conversationMessages']);
    Route::get('/unread/count', [MessageController::class, 'unreadCount']);
    Route::post('/{id}/read', [MessageController::class, 'markAsRead']);
    Route::post('/{id}/archive', [MessageController::class, 'archive']);
    Route::post('/conversation/{userId}/archive', [MessageController::class, 'archiveConversation']);
    Route::post('/conversation/{userId}/unarchive', [MessageController::class, 'unarchiveConversation']);
});

// Routes des notifications
Route::middleware('auth:sanctum')->prefix('notifications')->group(function () {
    Route::get('/', [NotificationController::class, 'index']);
    Route::get('/unread', [NotificationController::class, 'unread']);
    Route::get('/count/unread', [NotificationController::class, 'unreadCount']);
    Route::get('/type/{type}', [NotificationController::class, 'byType']);
    Route::post('/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/read/all', [NotificationController::class, 'markAllAsRead']);
    Route::post('/{id}/archive', [NotificationController::class, 'archive']);
    Route::delete('/{id}', [NotificationController::class, 'destroy']);
});

// Routes des favoris
Route::middleware('auth:sanctum')->prefix('favorites')->group(function () {
    Route::post('/{productId}', [FavoriteController::class, 'store']);
    Route::delete('/{productId}', [FavoriteController::class, 'destroy']);
    Route::get('/', [FavoriteController::class, 'index']);
    Route::get('/check/{productId}', [FavoriteController::class, 'check']);
    Route::get('/{id}', [FavoriteController::class, 'show']);
});

// Routes des signalements
Route::middleware('auth:sanctum')->prefix('reports')->group(function () {
    Route::post('/', [ReportController::class, 'store']);
});

// Routes de monitoring
Route::prefix('monitoring')->group(function () {
    Route::get('/health', function () {
        return response()->json(['status' => 'healthy']);
    });

    Route::middleware('auth:sanctum')->get('/metrics', function () {
        // À implémenter selon vos besoins
        return response()->json(['message' => 'Metrics endpoint']);
    });
});

// Route pour récupérer les produits de l'utilisateur connecté
Route::get('/users/me/products', [App\Http\Controllers\API\ProductController::class, 'getUserProducts'])->middleware('auth:sanctum');
