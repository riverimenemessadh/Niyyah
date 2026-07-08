<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    // REGISTER
    // Creates a new user and returns a token immediately
    public function register(Request $request)
    {
        // Validate the incoming data
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        // Create the user — password is auto-hashed because
        // of the 'hashed' cast in the User model
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Create a Sanctum token for this user
        // 'auth_token' is just a label for the token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user'  => $user,
            'token' => $token,
        ], 201); // 201 = Created
    }

    // LOGIN
    // Checks credentials and returns a token if correct
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        // Check if email exists and password matches
        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user = User::where('email', $request->email)->firstOrFail();

        // Delete old tokens to avoid buildup, then create a fresh one
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user'  => $user,
            'token' => $token,
        ]);
    }

    // LOGOUT
    // Deletes the current token so it can't be used anymore
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    // GET CURRENT USER
    // Returns the logged-in user's data based on their token
    public function me(Request $request)
    {
        return response()->json($request->user());
    }
    // UPDATE NAME
public function updateName(Request $request)
{
    $request->validate(['name' => 'required|string|max:255']);
    $request->user()->update(['name' => $request->name]);
    return response()->json(['message' => 'Name updated']);
}

// DELETE ACCOUNT
public function deleteAccount(Request $request)
{
    $user = $request->user();
    // Revoke all tokens first
    $user->tokens()->delete();
    // Delete the user and all their goals (cascade set in migration)
    $user->delete();
    return response()->json(['message' => 'Account deleted']);
}
}
