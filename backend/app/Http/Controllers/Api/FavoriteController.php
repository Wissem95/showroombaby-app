<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Product;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /**
     * Affiche la liste des favoris de l'utilisateur connecté
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $favorites = Favorite::with('product.seller', 'product.category', 'product.images')
            ->where('user_id', $request->user()->id)
            ->paginate(10);

        return response()->json([
            'data' => $favorites->items(),
            'meta' => [
                'current_page' => $favorites->currentPage(),
                'total' => $favorites->total(),
                'per_page' => $favorites->perPage(),
                'last_page' => $favorites->lastPage()
            ]
        ]);
    }

    /**
     * Ajoute un produit aux favoris
     *
     * @param Request $request
     * @param string $productId
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request, $productId)
    {
        // Vérification que le produit existe
        $product = Product::findOrFail($productId);

        // Vérification que l'utilisateur n'essaie pas d'ajouter son propre produit en favoris
        if ($product->user_id === $request->user()->id) {
            return response()->json([
                'message' => 'Vous ne pouvez pas ajouter votre propre produit en favoris'
            ], 422);
        }

        // Vérification que le favori n'existe pas déjà
        $existingFavorite = Favorite::where('user_id', $request->user()->id)
            ->where('product_id', $productId)
            ->first();

        if ($existingFavorite) {
            return response()->json([
                'message' => 'Ce produit est déjà dans vos favoris'
            ], 422);
        }

        // Création du favori
        $favorite = Favorite::create([
            'user_id' => $request->user()->id,
            'product_id' => $productId
        ]);

        // Chargement des relations
        $favorite->load('product.seller', 'product.category', 'product.images');

        return response()->json(['data' => $favorite], 201);
    }

    /**
     * Affiche les détails d'un favori spécifique
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        $favorite = Favorite::with('product.seller', 'product.category', 'product.images')
            ->findOrFail($id);

        // Vérifier que l'utilisateur a accès à ce favori
        if ($favorite->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Vous n\'êtes pas autorisé à voir ce favori'
            ], 403);
        }

        return response()->json(['data' => $favorite]);
    }

    /**
     * Supprime un favori
     *
     * @param Request $request
     * @param string $productId
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $productId)
    {
        $favorite = Favorite::where('user_id', $request->user()->id)
            ->where('product_id', $productId)
            ->firstOrFail();

        $favorite->delete();

        return response()->json(['message' => 'Produit retiré des favoris avec succès']);
    }

    /**
     * Vérifie si un produit est dans les favoris de l'utilisateur
     *
     * @param Request $request
     * @param string $productId
     * @return \Illuminate\Http\JsonResponse
     */
    public function check(Request $request, $productId)
    {
        $isFavorite = Favorite::where('user_id', $request->user()->id)
            ->where('product_id', $productId)
            ->exists();

        return response()->json([
            'isFavorite' => $isFavorite
        ]);
    }
}
