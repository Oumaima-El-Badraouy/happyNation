namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ResponseAnswer;
use App\Models\AIReport;
use Illuminate\Http\Request;

class StatisticsController extends Controller
{
    public function globalStats()
    {
        // Average scores
        $avgStress = AIReport::avg('diagnostic_json->stress_score');
        $avgMotivation = AIReport::avg('diagnostic_json->motivation_score');
        $avgSatisfaction = AIReport::avg('diagnostic_json->satisfaction_score');

        // Count responses
        $totalResponses = ResponseAnswer::count();

        return response()->json([
            'average_stress' => $avgStress,
            'average_motivation' => $avgMotivation,
            'average_satisfaction' => $avgSatisfaction,
            'total_responses' => $totalResponses,
        ]);
    }
}
