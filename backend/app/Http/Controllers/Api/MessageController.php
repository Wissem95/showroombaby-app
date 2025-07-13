<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class MessageController extends Controller
{
    /**
     * Envoyer un nouveau message
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $request->validate([
            'recipientId' => 'required|exists:users,id',
            'content' => 'required|string|max:1000',
            'productId' => 'nullable|exists:products,id',
        ]);

        $user = Auth::user();

        // Vérifier que l'utilisateur n'envoie pas de message à lui-même
        if ($user->id == $request->recipientId) {
            return response()->json([
                'message' => 'Vous ne pouvez pas vous envoyer un message à vous-même'
            ], 400);
        }

        // Si un productId est fourni, vérifier que le produit existe
        if ($request->has('productId') && $request->productId) {
            $product = Product::find($request->productId);
            if (!$product) {
                return response()->json([
                    'message' => 'Le produit spécifié n\'existe pas'
                ], 404);
            }
        }

        $message = Message::create([
            'content' => $request->content,
            'sender_id' => $user->id,
            'recipient_id' => $request->recipientId,
            'product_id' => $request->productId,
            'read' => false,
            'archived_by_sender' => false,
            'archived_by_recipient' => false,
        ]);

        return response()->json([
            'message' => 'Message envoyé avec succès',
            'data' => $message
        ], 201);
    }

    /**
     * Récupérer la liste des conversations de l'utilisateur
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function conversations(Request $request)
    {
        $user = Auth::user();

        // Récupérer les derniers messages pour chaque conversation
        $conversations = Message::with(['sender', 'recipient', 'product'])
            ->where(function($query) use ($user) {
                $query->where('sender_id', $user->id)
                      ->orWhere('recipient_id', $user->id);
            })
            ->whereRaw('(
                (sender_id = ? AND archived_by_sender = false) OR
                (recipient_id = ? AND archived_by_recipient = false)
            )', [$user->id, $user->id])
            ->orderBy('created_at', 'desc')
            ->get()
            ->groupBy(function($message) use ($user) {
                // Grouper par (utilisateur, produit) pour avoir des conversations distinctes par produit
                $otherUserId = $message->sender_id == $user->id ? $message->recipient_id : $message->sender_id;
                $productId = $message->product_id ?? 'general';
                return $otherUserId . '_' . $productId;
            })
            ->map(function($messages) use ($user) {
                $lastMessage = $messages->first();
                $otherUserId = $lastMessage->sender_id == $user->id ? $lastMessage->recipient_id : $lastMessage->sender_id;
                $otherUser = $lastMessage->sender_id == $user->id ? $lastMessage->recipient : $lastMessage->sender;

                // Compter les messages non lus de cette conversation SPÉCIFIQUE (même produit)
                $unreadQuery = Message::where('sender_id', $otherUserId)
                    ->where('recipient_id', $user->id)
                    ->where('read', false);

                // Appliquer le même filtre par produit que pour le groupement
                if ($lastMessage->product_id) {
                    $unreadQuery->where('product_id', $lastMessage->product_id);
                } else {
                    $unreadQuery->whereNull('product_id');
                }

                $unreadCount = $unreadQuery->count();

                return [
                    'otherUser' => [
                        'id' => $otherUser->id,
                        'name' => $otherUser->name,
                        'firstName' => $otherUser->firstName ?? '',
                        'lastName' => $otherUser->lastName ?? '',
                        'email' => $otherUser->email,
                        'avatar' => $otherUser->avatar,
                    ],
                    'lastMessage' => [
                        'id' => $lastMessage->id,
                        'content' => $lastMessage->content,
                        'senderId' => $lastMessage->sender_id,
                        'recipientId' => $lastMessage->recipient_id,
                        'createdAt' => $lastMessage->created_at,
                        'read' => $lastMessage->read,
                    ],
                    'unreadCount' => $unreadCount,
                    'product' => $lastMessage->product ? [
                        'id' => $lastMessage->product->id,
                        'title' => $lastMessage->product->title,
                        'price' => $lastMessage->product->price,
                    ] : null,
                ];
            })
            ->values();

        return response()->json([
            'data' => $conversations
        ]);
    }

    /**
     * Récupérer la liste des conversations archivées de l'utilisateur
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function archivedConversations(Request $request)
    {
        $user = Auth::user();
        $page = $request->input('page', 1);
        $limit = $request->input('limit', 10);

        // Récupérer les conversations archivées
        $conversations = $this->getConversationsQuery($user, true)
            ->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'data' => $conversations,
            'meta' => [
                'current_page' => $conversations->currentPage(),
                'last_page' => $conversations->lastPage(),
                'per_page' => $conversations->perPage(),
                'total' => $conversations->total()
            ]
        ]);
    }

    /**
     * Récupérer les messages d'une conversation avec un utilisateur spécifique
     *
     * @param Request $request
     * @param int $userId
     * @return \Illuminate\Http\JsonResponse
     */
    public function conversationMessages(Request $request, $userId)
    {
        $user = Auth::user();
        $page = $request->input('page', 1);
        $limit = $request->input('limit', 20);
                $productId = $request->input('productId'); // Récupérer le productId de la requête

        // Vérifier que l'utilisateur existe
        $otherUser = User::find($userId);
        if (!$otherUser) {
            return response()->json([
                'message' => 'Utilisateur non trouvé'
            ], 404);
        }

        // Récupérer les messages entre les deux utilisateurs pour un produit spécifique
        $query = Message::where(function($query) use ($user, $userId, $productId) {
                // Messages envoyés par l'utilisateur connecté
                $query->where(function($subQuery) use ($user, $userId, $productId) {
                    $subQuery->where('sender_id', $user->id)
                             ->where('recipient_id', $userId);

                    if ($productId) {
                        $subQuery->where('product_id', $productId);
                    } else {
                        $subQuery->whereNull('product_id');
                    }
                })
                // Messages reçus par l'utilisateur connecté
                ->orWhere(function($subQuery) use ($user, $userId, $productId) {
                    $subQuery->where('sender_id', $userId)
                             ->where('recipient_id', $user->id);

                    if ($productId) {
                        $subQuery->where('product_id', $productId);
                    } else {
                        $subQuery->whereNull('product_id');
                    }
                });
            });

        $messages = $query->with(['sender', 'product', 'product.seller', 'product.images'])
            ->orderBy('created_at', 'asc')
            ->paginate($limit, ['*'], 'page', $page);

        // Marquer comme lus SEULEMENT les messages de cette conversation spécifique
        $markAsReadQuery = Message::where('sender_id', $userId)
            ->where('recipient_id', $user->id)
            ->where('read', false);

        // Appliquer le même filtre par produit
        if ($productId) {
            $markAsReadQuery->where('product_id', $productId);
        } else {
            $markAsReadQuery->whereNull('product_id');
        }

        $markAsReadQuery->update(['read' => true]);

        // Formater les messages pour éviter les problèmes de sérialisation
        $formattedMessages = [];
        foreach ($messages->items() as $message) {
            $formattedMessages[] = [
                'id' => $message->id,
                'content' => $message->content,
                'senderId' => $message->sender_id,
                'recipientId' => $message->recipient_id,
                'productId' => $message->product_id,
                'read' => $message->read,
                'archivedBySender' => $message->archived_by_sender,
                'archivedByRecipient' => $message->archived_by_recipient,
                'sender' => $message->sender ? [
                    'id' => $message->sender->id,
                    'name' => $message->sender->name,
                    'firstName' => $message->sender->firstName,
                    'lastName' => $message->sender->lastName,
                    'username' => $message->sender->username,
                    'email' => $message->sender->email,
                    'avatar' => $message->sender->avatar,
                ] : null,
                'product' => $message->product ? [
                    'id' => $message->product->id,
                    'title' => $message->product->title,
                    'description' => $message->product->description,
                    'price' => $message->product->price,
                    'images' => $message->product->images ? $message->product->images->map(function($image) {
                        return [
                            'id' => $image->id,
                            'path' => $image->path,
                            'url' => asset('storage/' . $image->path),
                            'is_primary' => $image->is_primary,
                            'order' => $image->order
                        ];
                    })->toArray() : [], // Images du produit formatées, tableau vide si null
                    'address' => $message->product->address, // Adresse du produit
                    'city' => $message->product->city,
                    'postalCode' => $message->product->zipCode, // Corriger le nom du champ
                    'seller' => $message->product->seller ? [ // Informations du vendeur
                        'id' => $message->product->seller->id,
                        'name' => $message->product->seller->name,
                        'firstName' => $message->product->seller->firstName,
                        'lastName' => $message->product->seller->lastName,
                        'username' => $message->product->seller->username,
                        'avatar' => $message->product->seller->avatar,
                        'phone' => $message->product->seller->phone,
                    ] : null,
                ] : null,
                'createdAt' => $message->created_at,
                'updatedAt' => $message->updated_at,
            ];
        }

        return response()->json([
            'data' => $formattedMessages,
            'meta' => [
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
                'per_page' => $messages->perPage(),
                'total' => $messages->total()
            ]
        ]);
    }

    /**
     * Marquer un message comme lu
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function markAsRead(Request $request, $id)
    {
        $user = Auth::user();

        $message = Message::where('id', $id)
            ->where('recipient_id', $user->id)
            ->first();

        if (!$message) {
            return response()->json([
                'message' => 'Message non trouvé ou vous n\'êtes pas autorisé à le marquer comme lu'
            ], 404);
        }

        $message->markAsRead();

        return response()->json([
            'message' => 'Message marqué comme lu'
        ]);
    }

    /**
     * Archiver un message
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function archive(Request $request, $id)
    {
        $user = Auth::user();

        $message = Message::where('id', $id)
            ->where(function($query) use ($user) {
                $query->where('sender_id', $user->id)
                      ->orWhere('recipient_id', $user->id);
            })
            ->first();

        if (!$message) {
            return response()->json([
                'message' => 'Message non trouvé ou vous n\'êtes pas autorisé à l\'archiver'
            ], 404);
        }

        if ($message->sender_id == $user->id) {
            $message->archiveBySender();
        } else {
            $message->archiveByRecipient();
        }

        return response()->json([
            'message' => 'Message archivé'
        ]);
    }

    /**
     * Archiver une conversation entière avec un utilisateur
     *
     * @param Request $request
     * @param int $userId
     * @return \Illuminate\Http\JsonResponse
     */
    public function archiveConversation(Request $request, $userId)
    {
        $user = Auth::user();

        // Vérifier que l'utilisateur existe
        $otherUser = User::find($userId);
        if (!$otherUser) {
            return response()->json([
                'message' => 'Utilisateur non trouvé'
            ], 404);
        }

        // Archiver tous les messages envoyés par l'utilisateur
        Message::where('sender_id', $user->id)
            ->where('recipient_id', $userId)
            ->update(['archived_by_sender' => true]);

        // Archiver tous les messages reçus par l'utilisateur
        Message::where('sender_id', $userId)
            ->where('recipient_id', $user->id)
            ->update(['archived_by_recipient' => true]);

        return response()->json([
            'message' => 'Conversation archivée'
        ]);
    }

    /**
     * Désarchiver une conversation entière avec un utilisateur
     *
     * @param Request $request
     * @param int $userId
     * @return \Illuminate\Http\JsonResponse
     */
    public function unarchiveConversation(Request $request, $userId)
    {
        $user = Auth::user();

        // Vérifier que l'utilisateur existe
        $otherUser = User::find($userId);
        if (!$otherUser) {
            return response()->json([
                'message' => 'Utilisateur non trouvé'
            ], 404);
        }

        // Désarchiver tous les messages envoyés par l'utilisateur
        Message::where('sender_id', $user->id)
            ->where('recipient_id', $userId)
            ->update(['archived_by_sender' => false]);

        // Désarchiver tous les messages reçus par l'utilisateur
        Message::where('sender_id', $userId)
            ->where('recipient_id', $user->id)
            ->update(['archived_by_recipient' => false]);

        return response()->json([
            'message' => 'Conversation désarchivée'
        ]);
    }

    /**
     * Récupérer le nombre de messages non lus
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function unreadCount()
    {
        $user = Auth::user();

        $count = Message::where('recipient_id', $user->id)
            ->where('read', false)
            ->count();

        return response()->json([
            'count' => $count
        ]);
    }

    /**
     * Requête pour récupérer les conversations
     *
     * @param User $user
     * @param bool $archived
     * @return \Illuminate\Database\Query\Builder
     */
    private function getConversationsQuery($user, $archived = false)
    {
        // Inclure l'ID du produit et créer une requête plus complète
        return DB::table('messages')
            ->select(
                'messages.id',
                'messages.sender_id',
                'messages.recipient_id',
                'messages.content',
                'messages.created_at',
                'messages.read',
                'messages.product_id',
                'messages.archived_by_sender',
                'messages.archived_by_recipient',
                'sender.id as sender_id',
                'sender.username as sender_username',
                'sender.email as sender_email',
                'sender.avatar as sender_avatar',
                'recipient.id as recipient_id',
                'recipient.username as recipient_username',
                'recipient.email as recipient_email',
                'recipient.avatar as recipient_avatar',
                'products.id as product_id',
                'products.title as product_title',
                'products.price as product_price'
            )
            ->join('users as sender', 'messages.sender_id', '=', 'sender.id')
            ->join('users as recipient', 'messages.recipient_id', '=', 'recipient.id')
            ->leftJoin('products', 'messages.product_id', '=', 'products.id')
            ->where(function($query) use ($user) {
                $query->where('sender_id', $user->id)
                    ->orWhere('recipient_id', $user->id);
            })
            ->orderBy('messages.created_at', 'desc');
    }
}
