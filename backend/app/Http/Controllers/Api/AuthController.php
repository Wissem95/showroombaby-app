<?php

namespace App\Http\Controllers\API;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Inscription d'un nouvel utilisateur
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
            'username' => 'required|unique:users|min:3'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Erreur de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'username' => $request->username,
            'name' => $request->username,
            'firstName' => '',
            'lastName' => '',
            'phone' => '',
            'street' => '',
            'city' => '',
            'zipCode' => '',
            'country' => '',
            'latitude' => 0,
            'longitude' => 0,
            'rating' => 0.0,
            'isEmailVerified' => false,
            'role' => 'USER'
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Inscription réussie',
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'username' => $user->username,
                'name' => $user->name,
                'firstName' => $user->firstName,
                'lastName' => $user->lastName,
                'phone' => $user->phone,
                'street' => $user->street,
                'city' => $user->city,
                'zipCode' => $user->zipCode
            ],
            'access_token' => $token
        ], 201);
    }

    /**
     * Connexion d'un utilisateur
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Erreur de validation',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Identifiants invalides'
            ], 401);
        }

        // Supprimer les anciens tokens
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'message' => 'Connexion réussie',
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'username' => $user->username
            ]
        ]);
    }

    /**
     * Déconnexion d'un utilisateur
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie'
        ]);
    }

    /**
     * Vérifier la validité du token d'authentification
     */
    public function check(Request $request)
    {
        return response()->json([
            'message' => 'Token valide',
            'user' => $request->user()
        ]);
    }
}
