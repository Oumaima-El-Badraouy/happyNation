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
    ]);

    $settings = AISetting::firstOrFail();

    // risk_levels static
    $riskLevels = [
        ["min" => 0,  "max" => 30, "label" => "low"],
        ["min" => 31, "max" => 70, "label" => "medium"],
        ["min" => 71, "max" => 100, "label" => "high"]
    ];

    $settings->update(array_merge(
        $request->only([
            'stress_weight',
            'motivation_weight',
            'satisfaction_weight',
        ]),
        [
            'risk_levels' => json_encode($riskLevels),  // store as JSON
            'model' => 'gemini-2.5-flash',
        ]
    ));

    return response()->json([
        'message' => 'AI settings updated',
        'settings' => $settings
    ]);
}

}
