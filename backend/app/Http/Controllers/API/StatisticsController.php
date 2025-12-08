<?php
namespace App\Http\Controllers\API;

use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Models\ResponseAnswer;
use App\Models\AIReport;

class StatisticsController extends Controller
{
    public function globalStats()
    {
        $user = Auth::user();

        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Récupérer toutes les entrées JSON
        $reports = AIReport::all()->pluck('diagnostic_json');

        // Décoder chaque JSON et récupérer les scores
        $stressScores = $reports->map(function($r) {
            $data = json_decode($r, true);
            return $data['stress_score'] ?? 0;
        });

        $motivationScores = $reports->map(function($r) {
            $data = json_decode($r, true);
            return $data['motivation_score'] ?? 0;
        });

        $satisfactionScores = $reports->map(function($r) {
            $data = json_decode($r, true);
            return $data['satisfaction_score'] ?? 0;
        });

        // Calcul des moyennes
        $avgStress = round($stressScores->avg(), 2);
        $avgMotivation = round($motivationScores->avg(), 2);
        $avgSatisfaction = round($satisfactionScores->avg(), 2);

        // Nombre total de réponses
        $totalResponses = ResponseAnswer::count();

        return response()->json([
            'average_stress' => $avgStress,
            'average_motivation' => $avgMotivation,
            'average_satisfaction' => $avgSatisfaction,
            'total_responses' => $totalResponses,
        ]);
    }
}
