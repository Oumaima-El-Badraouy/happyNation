<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Frequency;
use Illuminate\Support\Facades\Auth;

class FrequencyController extends Controller
{
    // ==========================
    // Liste toutes les fréquences
    // ==========================
    public function index()
    {
        $frequencies = Frequency::all();
        return response()->json($frequencies);
    }
    // ==========================
    // Mettre à jour une fréquence
    // ==========================
    public function update(Request $request, )
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $frequency = Frequency::first();

        $request->validate([
            'frequency' => 'required|string|in:daily,weekly,monthly',
        ]);

        $frequency->update([
            'frequency' => $request->input('frequency')
        ]);

        return response()->json([
            'message' => 'Frequency updated successfully',
            'frequency' => $frequency
        ]);
    }
}
