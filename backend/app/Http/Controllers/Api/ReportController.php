<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\Product;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    /**
     * Affiche la liste des signalements (admin uniquement)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        // Vérification que l'utilisateur est admin
        if ($request->user()->role !== 'ADMIN') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        $reports = Report::with(['reporter', 'product'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'items' => $reports->items(),
            'total' => $reports->total(),
            'page' => $reports->currentPage(),
            'limit' => $reports->perPage(),
            'totalPages' => $reports->lastPage()
        ]);
    }

    /**
     * Crée un nouveau signalement
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        // Validation des données
        $request->validate([
            'productId' => 'required|exists:products,id',
            'reason' => 'required|string|in:inappropriate,fake,offensive,spam,other',
            'description' => 'required|string|max:500',
        ]);

        // Vérification que le produit existe
        $product = Product::findOrFail($request->productId);

        // Vérification que l'utilisateur n'a pas déjà signalé ce produit
        $existingReport = Report::where('reporter_id', $request->user()->id)
            ->where('product_id', $request->productId)
            ->first();

        if ($existingReport) {
            return response()->json([
                'message' => 'Vous avez déjà signalé ce produit'
            ], 400);
        }

        // Création du signalement
        $report = Report::create([
            'reporter_id' => $request->user()->id,
            'product_id' => $request->productId,
            'reason' => $request->reason,
            'description' => $request->description,
            'status' => 'pending'
        ]);

        // Chargement des relations
        $report->load(['reporter', 'product']);

        return response()->json($report, 201);
    }

    /**
     * Affiche les détails d'un signalement (admin uniquement)
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        // Vérification que l'utilisateur est admin
        if ($request->user()->role !== 'ADMIN') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        $report = Report::with(['reporter', 'product'])
            ->findOrFail($id);

        return response()->json($report);
    }

    /**
     * Met à jour le statut d'un signalement (admin uniquement)
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        // Vérification que l'utilisateur est admin
        if ($request->user()->role !== 'ADMIN') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        $report = Report::findOrFail($id);

        // Validation des données
        $request->validate([
            'status' => 'required|string|in:pending,reviewed,resolved,rejected',
            'moderationNote' => 'sometimes|string|max:500',
        ]);

        // Mise à jour des champs
        $report->status = $request->status;
        if ($request->has('moderationNote')) {
            $report->moderation_note = $request->moderationNote;
        }

        $report->save();

        // Chargement des relations
        $report->load(['reporter', 'product']);

        return response()->json($report);
    }
}
