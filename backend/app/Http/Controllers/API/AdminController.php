<?php

namespace App\Http\Controllers\API;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    // ===========================
    // List all users
    // ===========================
    public function index()
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $users = User::all();
        return response()->json($users);
    }

    // ===========================
    // Show single user
    // ===========================
    public function show($id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $target = User::find($id);
        if (!$target) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json($target);
    }

    // ===========================
    // Update user
    // ===========================
    public function update(Request $request, $id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $target = User::find($id);
        if (!$target) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email'=> 'sometimes|email|unique:users,email,' . $id,
            'password'=> 'sometimes|string|min:6|confirmed',
            'role' => 'sometimes|string|in:user,admin',
        ]);

        if ($request->has('name')) $target->name = $request->name;
        if ($request->has('email')) $target->email = $request->email;
        if ($request->has('password')) $target->password = Hash::make($request->password);
        if ($request->has('role')) $target->role = $request->role;

        $target->save();

        return response()->json(['message' => 'User updated', 'user' => $target]);
    }

    // ===========================
    // Delete user
    // ===========================
    public function destroy($id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $target = User::find($id);
        if (!$target) {
            return response()->json(['message' => 'User not found'], 404);
        }

        $target->delete();

        return response()->json(['message' => 'User deleted']);
    }
}
