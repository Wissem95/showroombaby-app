<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Models\Category;
use Illuminate\Support\Facades\Log;

class AddSubcategories extends Migration
{
    public function up()
    {
        // Supprimer les catégories redondantes (21-30)
        Category::whereBetween('id', [21, 30])->delete();

        // Supprimer les doublons (garder les premiers IDs)
        $duplicates = [
            // Poussette
            ['name' => 'Poussette canne', 'keep' => 31, 'delete' => 121],
            ['name' => 'Poussette 3 roues', 'keep' => 32, 'delete' => 122],
            ['name' => 'Poussette 4 roues', 'keep' => 33, 'delete' => 123],
            ['name' => 'Poussette combiné duo', 'keep' => 34, 'delete' => 124],
            ['name' => 'Poussette combiné trio', 'keep' => 35, 'delete' => 125],
            ['name' => 'Poussette double', 'keep' => 36, 'delete' => 126],
            ['name' => 'Poussette tout terrain', 'keep' => 37, 'delete' => 127],

            // Sièges auto
            ['name' => 'Groupe 0/0+', 'keep' => 38, 'delete' => 128],
            ['name' => 'Groupe 0+/1', 'keep' => 39, 'delete' => 129],
            ['name' => 'Groupe 1', 'keep' => 40, 'delete' => 130],
            ['name' => 'Groupe 2/3', 'keep' => 41, 'delete' => 131],
            ['name' => 'Groupe 1/2/3', 'keep' => 42, 'delete' => 132],
            ['name' => 'Siège auto pivotant', 'keep' => 43, 'delete' => 133],
        ];

        foreach ($duplicates as $duplicate) {
            Category::where('id', $duplicate['delete'])->delete();
        }

        // Supprimer les sous-catégories en double (IDs 134-210)
        Category::whereBetween('id', [134, 210])->delete();

        // Mettre à jour les parent_id pour les sous-catégories
        $subcategories = [
            // Poussette (id: 1)
            ['ids' => [31, 32, 33, 34, 35, 36, 37], 'parent_id' => 1],
            // Sièges auto (id: 2)
            ['ids' => [38, 39, 40, 41, 42, 43], 'parent_id' => 2],
            // Chambre (id: 3)
            ['ids' => [44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60], 'parent_id' => 3],
            // Chaussure / Vêtements (id: 4)
            ['ids' => [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78], 'parent_id' => 4],
            // Jeux / Éveil (id: 5)
            ['ids' => [79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91], 'parent_id' => 5],
            // Livre / Dvd (id: 6)
            ['ids' => [92, 93, 94, 95, 96], 'parent_id' => 6],
            // Toilette (id: 7)
            ['ids' => [97, 98, 99, 100, 101, 102, 103, 104, 105], 'parent_id' => 7],
            // Repas (id: 8)
            ['ids' => [106, 107, 108, 109, 110, 111, 112, 113, 114], 'parent_id' => 8],
            // Sortie (id: 9)
            ['ids' => [115, 116, 117, 118], 'parent_id' => 9],
            // Service (id: 10)
            ['ids' => [119, 120], 'parent_id' => 10]
        ];

        foreach ($subcategories as $group) {
            Category::whereIn('id', $group['ids'])->update(['parent_id' => $group['parent_id']]);
        }
    }

    public function down()
    {
        // En cas de rollback, on ne fait rien car on ne veut pas recréer les doublons
    }
}
