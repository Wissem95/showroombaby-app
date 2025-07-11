<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Liste des notifications
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = Auth::user();
        $page = $request->input('page', 1);
        $limit = $request->input('limit', 10);

        $notifications = Notification::where('user_id', $user->id)
            ->where('status', '!=', 'archived')
            ->orderBy('created_at', 'desc')
            ->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'data' => $notifications,
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total()
            ]
        ]);
    }

    /**
     * Notifications non lues
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function unread()
    {
        $user = Auth::user();

        $notifications = Notification::where('user_id', $user->id)
            ->where('status', 'unread')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $notifications
        ]);
    }

    /**
     * Nombre de notifications non lues
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function unreadCount()
    {
        $user = Auth::user();

        $count = Notification::where('user_id', $user->id)
            ->where('status', 'unread')
            ->count();

        return response()->json([
            'count' => $count
        ]);
    }

    /**
     * Notifications par type
     *
     * @param string $type
     * @return \Illuminate\Http\JsonResponse
     */
    public function byType($type)
    {
        $user = Auth::user();

        // Vérifier que le type est valide
        if (!in_array($type, ['message', 'product', 'system', 'favorite', 'report'])) {
            return response()->json([
                'message' => 'Type de notification invalide'
            ], 400);
        }

        $notifications = Notification::where('user_id', $user->id)
            ->where('type', $type)
            ->where('status', '!=', 'archived')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $notifications
        ]);
    }

    /**
     * Marquer une notification comme lue
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function markAsRead($id)
    {
        $user = Auth::user();

        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$notification) {
            return response()->json([
                'message' => 'Notification non trouvée'
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'message' => 'Notification marquée comme lue'
        ]);
    }

    /**
     * Marquer toutes les notifications comme lues
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function markAllAsRead()
    {
        $user = Auth::user();

        Notification::where('user_id', $user->id)
            ->where('status', 'unread')
            ->update(['status' => 'read']);

        return response()->json([
            'message' => 'Toutes les notifications ont été marquées comme lues'
        ]);
    }

    /**
     * Archiver une notification
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function archive($id)
    {
        $user = Auth::user();

        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$notification) {
            return response()->json([
                'message' => 'Notification non trouvée'
            ], 404);
        }

        $notification->archive();

        return response()->json([
            'message' => 'Notification archivée'
        ]);
    }

    /**
     * Supprimer une notification
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $user = Auth::user();

        $notification = Notification::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$notification) {
            return response()->json([
                'message' => 'Notification non trouvée'
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'message' => 'Notification supprimée'
        ]);
    }
}
