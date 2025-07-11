<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    /**
     * Retourne la liste complète des catégories avec leurs sous-catégories
     *
     * @return array
     */
    public function getCategoriesWithSubcategories(): array
    {
        return [
            [
                'id' => 1,
                'name' => 'Poussette',
                'subcategories' => [
                    ['id' => 1, 'name' => 'Poussette canne'],
                    ['id' => 2, 'name' => 'Poussette 3 roues'],
                    ['id' => 3, 'name' => 'Poussette 4 roues'],
                    ['id' => 4, 'name' => 'Poussette combiné duo'],
                    ['id' => 5, 'name' => 'Poussette combiné trio'],
                    ['id' => 6, 'name' => 'Poussette double'],
                    ['id' => 7, 'name' => 'Poussette tout terrain'],
                ]
            ],
            [
                'id' => 2,
                'name' => 'Sièges auto',
                'subcategories' => [
                    ['id' => 8, 'name' => 'Groupe 0/0+'],
                    ['id' => 9, 'name' => 'Groupe 0+/1'],
                    ['id' => 10, 'name' => 'Groupe 1'],
                    ['id' => 11, 'name' => 'Groupe 2/3'],
                    ['id' => 12, 'name' => 'Groupe 1/2/3'],
                    ['id' => 13, 'name' => 'Siège auto pivotant'],
                ]
            ],
            [
                'id' => 3,
                'name' => 'Chambre',
                'subcategories' => [
                    ['id' => 14, 'name' => 'Applique et suspension'],
                    ['id' => 15, 'name' => 'Armoire'],
                    ['id' => 16, 'name' => 'Berceau bébé'],
                    ['id' => 17, 'name' => 'Bibliothèque'],
                    ['id' => 18, 'name' => 'Bureau'],
                    ['id' => 19, 'name' => 'Coffre à jouet'],
                    ['id' => 20, 'name' => 'Commode'],
                    ['id' => 21, 'name' => 'Deco/ lampe'],
                    ['id' => 22, 'name' => 'Lit bébé'],
                    ['id' => 23, 'name' => 'Lit enfant'],
                    ['id' => 24, 'name' => 'Lit mezzanine'],
                    ['id' => 25, 'name' => 'Matelas'],
                    ['id' => 26, 'name' => 'Parc à bébé'],
                    ['id' => 27, 'name' => 'Table à langer'],
                    ['id' => 28, 'name' => 'Table de nuit'],
                    ['id' => 29, 'name' => 'Tiroir de lit'],
                    ['id' => 30, 'name' => 'Tour de lit'],
                ]
            ],
            [
                'id' => 4,
                'name' => 'Chaussure / Vêtements',
                'subcategories' => [
                    ['id' => 31, 'name' => 'Gigoteuse'],
                    ['id' => 32, 'name' => 'Pyjama'],
                    ['id' => 33, 'name' => 'T-shirt'],
                    ['id' => 34, 'name' => 'Body'],
                    ['id' => 35, 'name' => 'Salopette / Combinaison'],
                    ['id' => 36, 'name' => 'Pantalon / Jean'],
                    ['id' => 37, 'name' => 'Pull / Gilet / Sweat'],
                    ['id' => 38, 'name' => 'Robe / Jupe'],
                    ['id' => 39, 'name' => 'Short'],
                    ['id' => 40, 'name' => 'Chemise / Blouse'],
                    ['id' => 41, 'name' => 'Legging'],
                    ['id' => 42, 'name' => 'Maillot de bain'],
                    ['id' => 43, 'name' => 'Manteau / Blouson'],
                    ['id' => 44, 'name' => 'Chaussure'],
                    ['id' => 45, 'name' => 'Basket'],
                    ['id' => 46, 'name' => 'Chausson'],
                    ['id' => 47, 'name' => 'Chaussette'],
                    ['id' => 48, 'name' => 'Culotte'],
                ]
            ],
            [
                'id' => 5,
                'name' => 'Jeux / Éveil',
                'subcategories' => [
                    ['id' => 49, 'name' => 'Transat'],
                    ['id' => 50, 'name' => 'Balancelle / Bascule'],
                    ['id' => 51, 'name' => 'Ballon'],
                    ['id' => 52, 'name' => 'Trotteur / Porteur/ Chariot'],
                    ['id' => 53, 'name' => 'Vélo'],
                    ['id' => 54, 'name' => 'Doudou / Peluche'],
                    ['id' => 55, 'name' => 'Tapis d\'éveil'],
                    ['id' => 56, 'name' => 'Jouet de bain'],
                    ['id' => 57, 'name' => 'Jouet en bois'],
                    ['id' => 58, 'name' => 'Poupon / Poupée'],
                    ['id' => 59, 'name' => 'Jeu de construction'],
                    ['id' => 60, 'name' => 'Figurine'],
                    ['id' => 61, 'name' => 'Puzzle'],
                ]
            ],
            [
                'id' => 6,
                'name' => 'Livre / Dvd',
                'subcategories' => [
                    ['id' => 62, 'name' => 'Livre sonore'],
                    ['id' => 63, 'name' => 'Éveil et premier âge'],
                    ['id' => 64, 'name' => 'Livre 0 mois à 2 ans'],
                    ['id' => 65, 'name' => 'Livre 2 ans à 4 ans'],
                    ['id' => 66, 'name' => 'Livre de bain'],
                ]
            ],
            [
                'id' => 7,
                'name' => 'Toilette',
                'subcategories' => [
                    ['id' => 67, 'name' => 'Baignoire'],
                    ['id' => 68, 'name' => 'Couche réutilisable'],
                    ['id' => 69, 'name' => 'Housse matelas à langer'],
                    ['id' => 70, 'name' => 'Matelas à langer'],
                    ['id' => 71, 'name' => 'Mouche bébé'],
                    ['id' => 72, 'name' => 'Peigne / Brosse'],
                    ['id' => 73, 'name' => 'Table à langer'],
                    ['id' => 74, 'name' => 'Thermomètre de bain'],
                    ['id' => 75, 'name' => 'Trousse de toilette'],
                ]
            ],
            [
                'id' => 8,
                'name' => 'Repas',
                'subcategories' => [
                    ['id' => 76, 'name' => 'Allaitement'],
                    ['id' => 77, 'name' => 'Boîte'],
                    ['id' => 78, 'name' => 'Boîte doseurs'],
                    ['id' => 79, 'name' => 'Chaise haute bebe'],
                    ['id' => 80, 'name' => 'Chauffe biberon'],
                    ['id' => 81, 'name' => 'Chauffe repas'],
                    ['id' => 82, 'name' => 'Coussin pour chaise haute'],
                    ['id' => 83, 'name' => 'Vaisselle'],
                    ['id' => 84, 'name' => 'Soutien gorge allaitement'],
                ]
            ],
            [
                'id' => 9,
                'name' => 'Sortie',
                'subcategories' => [
                    ['id' => 85, 'name' => 'Chancelière'],
                    ['id' => 86, 'name' => 'Lit pliant'],
                    ['id' => 87, 'name' => 'Sac a langer'],
                    ['id' => 88, 'name' => 'Porte bébé'],
                ]
            ],
            [
                'id' => 10,
                'name' => 'Service',
                'subcategories' => [
                    ['id' => 89, 'name' => 'Garde d\'enfant'],
                    ['id' => 90, 'name' => 'Aide au devoir'],
                ]
            ]
        ];
    }

    /**
     * Affiche la liste de toutes les catégories
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $categoriesWithSubcategories = $this->getCategoriesWithSubcategories();
        $dbCategories = Category::all();

        // Fusionner les données de la base avec les sous-catégories définies statiquement
        foreach ($categoriesWithSubcategories as $key => $category) {
            $dbCategory = $dbCategories->firstWhere('id', $category['id']);
            if ($dbCategory) {
                $categoriesWithSubcategories[$key]['description'] = $dbCategory->description;
            }
        }

        return response()->json(['data' => $categoriesWithSubcategories]);
    }

    /**
     * Stocke une nouvelle catégorie dans la base de données
     * Réservé aux administrateurs
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        // Vérification que l'utilisateur est admin
        if ($request->user()->role !== 'ADMIN') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        // Validation des données
        $request->validate([
            'name' => 'required|string|max:255|unique:categories',
            'description' => 'required|string',
        ]);

        // Création de la catégorie
        $category = Category::create([
            'name' => $request->name,
            'description' => $request->description,
        ]);

        return response()->json(['data' => $category], 201);
    }

    /**
     * Affiche les détails d'une catégorie spécifique
     *
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $category = Category::with('products')->findOrFail($id);
        return response()->json(['data' => $category]);
    }

    /**
     * Met à jour une catégorie existante
     * Réservé aux administrateurs
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

        $category = Category::findOrFail($id);

        // Validation des données
        $request->validate([
            'name' => 'sometimes|string|max:255|unique:categories,name,' . $id,
            'description' => 'sometimes|string',
        ]);

        // Mise à jour des champs
        if ($request->has('name')) $category->name = $request->name;
        if ($request->has('description')) $category->description = $request->description;

        $category->save();

        return response()->json(['data' => $category]);
    }

    /**
     * Supprime une catégorie
     * Réservé aux administrateurs
     *
     * @param Request $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        // Vérification que l'utilisateur est admin
        if ($request->user()->role !== 'ADMIN') {
            return response()->json(['message' => 'Non autorisé'], 403);
        }

        $category = Category::findOrFail($id);

        // Vérification que la catégorie n'a pas de produits associés
        if ($category->products()->count() > 0) {
            return response()->json([
                'message' => 'Impossible de supprimer une catégorie contenant des produits'
            ], 400);
        }

        $category->delete();

        return response()->json(['message' => 'Catégorie supprimée avec succès']);
    }
}
