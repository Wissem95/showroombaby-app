<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    use HasFactory;

    /**
     * Les attributs qui sont mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'content',
        'sender_id',
        'recipient_id',
        'product_id',
        'read',
        'archived_by_sender',
        'archived_by_recipient',
    ];

    /**
     * Les attributs qui doivent être castés.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'read' => 'boolean',
        'archived_by_sender' => 'boolean',
        'archived_by_recipient' => 'boolean',
    ];

    /**
     * Obtenir l'expéditeur du message
     */
    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Obtenir le destinataire du message
     */
    public function recipient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recipient_id');
    }

    /**
     * Obtenir le produit associé au message (s'il existe)
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Marquer le message comme lu
     */
    public function markAsRead(): void
    {
        if (!$this->read) {
            $this->update(['read' => true]);
        }
    }

    /**
     * Archiver le message pour l'expéditeur
     */
    public function archiveBySender(): void
    {
        if (!$this->archived_by_sender) {
            $this->update(['archived_by_sender' => true]);
        }
    }

    /**
     * Archiver le message pour le destinataire
     */
    public function archiveByRecipient(): void
    {
        if (!$this->archived_by_recipient) {
            $this->update(['archived_by_recipient' => true]);
        }
    }

    /**
     * Désarchiver le message pour l'expéditeur
     */
    public function unarchiveBySender(): void
    {
        if ($this->archived_by_sender) {
            $this->update(['archived_by_sender' => false]);
        }
    }

    /**
     * Désarchiver le message pour le destinataire
     */
    public function unarchiveByRecipient(): void
    {
        if ($this->archived_by_recipient) {
            $this->update(['archived_by_recipient' => false]);
        }
    }
}
