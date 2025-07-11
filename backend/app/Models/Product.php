<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    use HasFactory;

    /**
     * Les attributs qui sont mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'title',
        'description',
        'price',
        'condition',
        'status',
        'view_count',
        'latitude',
        'longitude',
        'address',
        'city',
        'zipCode',
        'phone',
        'hide_phone',
        'category_id',
        'subcategory_id',
        'user_id',
        'brand',
    ];

    /**
     * Les attributs qui doivent être castés.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'price' => 'float',
        'view_count' => 'integer',
        'latitude' => 'float',
        'longitude' => 'float',
        'hide_phone' => 'boolean',
    ];

    /**
     * Obtenir la catégorie du produit.
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Obtenir la sous-catégorie du produit.
     */
    public function subcategory(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'subcategory_id');
    }

    /**
     * Obtenir le vendeur du produit.
     */
    public function seller(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Obtenir les images du produit
     */
    public function images(): HasMany
    {
        return $this->hasMany(ProductImage::class);
    }

    /**
     * Obtenir l'image principale du produit
     */
    public function primaryImage()
    {
        return $this->images()->where('is_primary', true)->first();
    }

    /**
     * Obtenir les favoris du produit
     */
    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    /**
     * Obtenir les messages concernant ce produit
     */
    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }

    /**
     * Obtenir les signalements du produit
     */
    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }

    /**
     * Incrémente le compteur de vues
     */
    public function incrementViewCount(): void
    {
        $this->increment('view_count');
    }
}
