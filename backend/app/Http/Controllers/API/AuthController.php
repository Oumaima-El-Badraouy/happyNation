<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ===========================
    //Register)
    // ===========================
 public function register(Request $request)
{
    if (!Auth::check() || Auth::user()->role !== 'admin') {
        return response()->json([
            'message' => 'Only admins can create new accounts.'
        ], 403);
    }

    $request->validate([
        'name' => 'required|string|max:255',
        'email'=> 'required|email|unique:users',
        'password'=> 'required|string|min:6|confirmed',
    ]);

    $user = User::create([
        'name' => $request->name,
        'email'=> $request->email,
        'password'=> Hash::make($request->password),
        'role'=> 'user',
    ]);

    return response()->json([
        'user'=> $user,
    ]);
}


    // ===========================
    //(Login)
    // ===========================
   public function login(Request $request)
{
    $request->validate([
        'email' => 'required|email',
        'password' => 'required|string',
    ]);


    $user = User::where('email', $request->email)->first();

    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Invalid login details'], 401);
    }
    $token = $user->createToken('HappyNation Personal Access')->accessToken;

    return response()->json([
        'access_token' => $token,
        'token_type'   => 'Bearer',
        'user'         => $user,
    ]);
}


    // ===========================
    //جLogout)
    // ===========================
    public function logout(Request $request)
    {
        $request->user()->token()->revoke(); // Passport token revoke

        return response()->json(['message'=>'Logged out successfully']);
    }
}
