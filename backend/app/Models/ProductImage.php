<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProductImage extends Model
{
    use HasFactory;

    /**
     * Les attributs qui sont mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'path',
        'full_path',
        'is_primary',
        'order',
        'product_id',
    ];

    /**
     * Les attributs qui doivent être castés.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_primary' => 'boolean',
        'order' => 'integer',
    ];

    /**
     * Les attributs qui doivent être ajoutés au tableau.
     *
     * @var array<int, string>
     */
    protected $appends = ['url'];

    /**
     * Obtenir le produit associé à cette image
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Obtenir l'URL de l'image
     */
    public function getUrlAttribute(): string
    {
        if ($this->full_path) {
            return asset($this->full_path);
        }

        return asset('storage/' . $this->path);
    }
}
