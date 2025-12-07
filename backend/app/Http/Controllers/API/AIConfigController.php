<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AISetting;
use Illuminate\Support\Facades\Auth;

class AIConfigController extends Controller
{
    public function getSettings()
    {
         $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        $settings = AISetting::first();
        return response()->json($settings);
    }

    public function updateSettings(Request $request)
    {

         $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        $request->validate([
            'stress_weight' => 'nullable|numeric',
            'motivation_weight' => 'nullable|numeric',
            'satisfaction_weight' => 'nullable|numeric',
            'risk_levels' => 'nullable|array',
            'model' => 'nullable|string'
        ]);

        $settings = AISetting::firstOrFail();
        $settings->update($request->only([
            'stress_weight',
            'motivation_weight',
            'satisfaction_weight',
            'risk_levels',
            'model'
        ]));

        return response()->json(['message' => 'AI settings updated', 'settings' => $settings]);
    }
}
