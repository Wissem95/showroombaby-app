<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || $request->user()->role !== 'ADMIN') {
            return response()->json([
                'message' => 'Accès non autorisé. Seuls les administrateurs peuvent effectuer cette action.'
            ], 403);
        }

        return $next($request);
    }
}
