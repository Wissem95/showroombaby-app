<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    use HasFactory;

    /**
     * Les attributs qui sont mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'reporter_id',
        'product_id',
        'reason',
        'description',
        'status',
        'moderation_note',
    ];

    /**
     * Obtenir l'utilisateur qui a signalé
     */
    public function reporter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reporter_id');
    }

    /**
     * Obtenir le produit signalé
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Marquer le signalement comme examiné
     */
    public function markAsReviewed(string $note = null): void
    {
        $this->update([
            'status' => 'reviewed',
            'moderation_note' => $note,
        ]);
    }

    /**
     * Résoudre le signalement
     */
    public function resolve(string $note = null): void
    {
        $this->update([
            'status' => 'resolved',
            'moderation_note' => $note,
        ]);
    }

    /**
     * Rejeter le signalement
     */
    public function reject(string $note = null): void
    {
        $this->update([
            'status' => 'rejected',
            'moderation_note' => $note,
        ]);
    }
}
