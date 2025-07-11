<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{
    /**
     * Affiche le profil de l'utilisateur connecté
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        // On ne renvoie pas le mot de passe
        $user->makeHidden(['password']);

        return response()->json($user);
    }

    /**
     * Met à jour le profil de l'utilisateur connecté
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        // Log pour débuguer les données reçues
        Log::info('Données reçues pour la mise à jour du profil:', $request->all());

        // Validation des données
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users,email,' . $user->id,
            'username' => 'sometimes|string|max:255|unique:users,username,' . $user->id,
            'firstName' => 'sometimes|string|max:255',
            'lastName' => 'sometimes|string|max:255',
            'phone' => ['sometimes', 'nullable', 'string', 'max:12',
                        'regex:/^(0|\+33)[1-9](\d{2}){4}$/'], // Format français: 0612345678 ou +33612345678
            'avatar' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048',
            'street' => 'sometimes|string|max:255',
            'city' => 'sometimes|string|max:255',
            'zipCode' => 'sometimes|string|max:20',
            'address.street' => 'sometimes|string|max:255',
            'address.city' => 'sometimes|string|max:255',
            'address.zip_code' => 'sometimes|string|max:20',
        ], [
            'phone.regex' => 'Le numéro de téléphone doit être un format français valide (ex: 0612345678 ou +33612345678)'
        ]);

        // Mise à jour des champs avec valeurs par défaut si NULL
        if ($request->has('name')) {
            $user->name = $request->input('name') ?: ''; // Valeur vide si NULL
        }

        if ($request->has('email')) {
            $user->email = $request->input('email');  // Email ne peut pas être vide
        }

        if ($request->has('username')) {
            $user->username = $request->input('username');  // Username ne peut pas être vide
        }

        if ($request->has('firstName')) {
            $user->firstName = $request->input('firstName') ?: '';
        }

        if ($request->has('lastName')) {
            $user->lastName = $request->input('lastName') ?: '';
        }

        if ($request->has('phone')) {
            $user->phone = $request->input('phone') ?: '';
        }

        // Traitement des champs d'adresse (structure à plat)
        if ($request->has('street')) {
            $user->street = $request->input('street') ?: '';
        }

        if ($request->has('city')) {
            $user->city = $request->input('city') ?: '';
        }

        if ($request->has('zipCode')) {
            $user->zipCode = $request->input('zipCode') ?: '';
        }

        // Traitement des champs d'adresse (structure imbriquée)
        if ($request->has('address')) {
            $address = $request->address;
            if (isset($address['street'])) {
                $user->street = $address['street'] ?: '';
            }
            if (isset($address['city'])) {
                $user->city = $address['city'] ?: '';
            }
            if (isset($address['zip_code'])) {
                $user->zipCode = $address['zip_code'] ?: '';
            }
        }

        // Traitement de l'avatar
        if ($request->hasFile('avatar')) {
            // Suppression de l'ancien avatar s'il existe
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }

            // Stockage du nouvel avatar
            $path = $request->file('avatar')->store('avatars', 'public');
            $user->avatar = $path;
        }

        $user->save();

        Log::info('Profil utilisateur mis à jour avec succès. ID: ' . $user->id);

        // On ne renvoie pas le mot de passe
        $user->makeHidden(['password']);

        return response()->json([
            'status' => 'success',
            'message' => 'Profil mis à jour avec succès',
            'data' => $user
        ]);
    }

    /**
     * Change le mot de passe de l'utilisateur connecté
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePassword(Request $request)
    {
        $user = $request->user();

        // Validation des données
        $request->validate([
            'oldPassword' => 'required|string',
            'newPassword' => ['required', 'confirmed', Password::defaults()],
        ]);

        // Vérification de l'ancien mot de passe
        if (!Hash::check($request->oldPassword, $user->password)) {
            throw ValidationException::withMessages([
                'oldPassword' => ['Le mot de passe actuel est incorrect.'],
            ]);
        }

        // Mise à jour du mot de passe
        $user->password = Hash::make($request->newPassword);
        $user->save();

        return response()->json(['message' => 'Mot de passe modifié avec succès']);
    }

    /**
     * Supprime le compte de l'utilisateur connecté
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteAccount(Request $request)
    {
        $user = $request->user();

        // Suppression de l'avatar s'il existe
        if ($user->avatar) {
            Storage::disk('public')->delete($user->avatar);
        }

        // Révocation de tous les tokens
        $user->tokens()->delete();

        // Suppression du compte
        $user->delete();

        return response()->json(['message' => 'Compte supprimé avec succès']);
    }

    /**
     * Affiche le profil d'un utilisateur spécifique
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function showProfile($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'Utilisateur non trouvé'
            ], 404);
        }

        // On ne renvoie pas le mot de passe
        $user->makeHidden(['password']);

        // Formater la réponse pour inclure toutes les informations utiles
        $response = [
            'status' => 'success',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username ?: $user->name,
                'email' => $user->email,
                'avatar' => $user->avatar,
                'firstName' => $user->firstName,
                'lastName' => $user->lastName,
                'rating' => $user->rating ?: 0,
                'created_at' => $user->created_at,
            ]
        ];

        return response()->json($response);
    }
}
