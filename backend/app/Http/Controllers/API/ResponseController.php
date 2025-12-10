<?php

namespace App\Http\Controllers\API;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Response;
use App\Models\ResponseAnswer;
use App\Models\Question;
use App\Models\AiReport;
use App\Models\AISetting;

use Illuminate\Support\Facades\Http;

class ResponseController extends Controller
{
    // ==========================
    // Store Employee Response
    // ==========================
  public function store(Request $request)
{
    $validated = $request->validate([
        'answers' => 'required|array',
    ]);

    // 1) Save main response
    $response = Response::create([
        'user_id' =>Auth::id(),
    ]);

    // 2) Save each answer
    foreach ($validated['answers'] as $questionId => $answer) {
        ResponseAnswer::create([
            'response_id' => $response->id,
            'question_id' => $questionId,
            'answer' => $answer,
        ]);
    }
$aiConfig = AISetting::first();

    // 3) Build AI prompt
   $payload = [
    "contents" => [
        [
            "parts" => [
                [
                    "text" => "Analyze these employee well-being answers and return JSON with stress_score, motivation_score, satisfaction_score, risk_level, summary, recommendations.\n\n"
                        . json_encode($validated['answers'])
                        . "\nUse these weights: stress_weight={$aiConfig->stress_weight}, motivation_weight={$aiConfig->motivation_weight}, satisfaction_weight={$aiConfig->satisfaction_weight}."
                        . "\nReturn risk_levels: " . json_encode($aiConfig->risk_levels)
                ]
            ]
        ]
    ]
];
$model = 'gemini-2.5-flash';

$gemini = Http::withHeaders([
    'Content-Type' => 'application/json',
    'X-goog-api-key' => env('GEMINI_API_KEY'),
])->post(
    "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent",
    $payload
);
    if (!$gemini->successful()) {
        return response()->json([
            'message' => 'AI request failed',
            'gemini_response' => $gemini->json()
        ], 500);
    }

    // 5) Extract clean JSON from Gemini response
    $text = $gemini->json()['candidates'][0]['content']['parts'][0]['text'];

    // remove backticks + ```json
    $cleanJson = preg_replace('/```json|```/', '', $text);

    // 6) Store AI result in ai_reports table
    // 6) Store AI result in ai_reports table
$aiReport = AiReport::create([
    'response_id' => $response->id,
    'diagnostic_json' => $cleanJson,
    'model' => 'gemini-2.5-flash'
]);

// 7) Extract recommendations and store for admin
$aiData = json_decode($cleanJson, true);
if(isset($aiData['recommendations'])){
    DB::table('admin_recommendations')->insert([
        'response_id' => $response->id,
        'recommendations' => json_encode($aiData['recommendations']),
        'created_at' => now(),
        'updated_at' => now()
    ]);
}

// 8) Return response to user WITHOUT recommendations
unset($aiData['recommendations']);

return response()->json([
    "message" => "Response saved successfully",
    "response_id" => $response->id,
    "ai_report" => $aiData
]);

}


    // ==========================
    // Gemini AI Integration
    // ==========================
    private function analyzeWithGemini($answers)
    {
        $payload = [
            "contents" => [[
                "parts" => [[
                    "text" => "Analyze employee well-being using these answers:\n" . json_encode($answers) .
    "\nReturn JSON with the following fields:\n" .
    json_encode([
        "stress_score" => "0-100",
        "motivation_score" => "0-100",
        "satisfaction_score" => "0-100",
        "risk_level" => "low | medium | high",
        "summary" => "string (write directly to the employee, friendly and motivating. Example: 'You seem a bit stressed, try taking small breaks and focusing on your goals.')",
        "recommendations" => ["string", "..."]
    ])

                ]]
            ]]
        ];

        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'),
        ])->post(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
            $payload
        );

        return json_decode($response->body(), true);
    }

    // ==========================
    // Get History of a user
    // ==========================
    public function history()
{
    $history = Response::where('user_id', Auth::id())
        ->with('aiReport') // <-- غير AI report
        ->orderBy('created_at', 'desc')
        ->get()
        ->map(function ($item) {
            return [
                'id' => $item->id,
                'created_at' => $item->created_at,
                'ai_report' => json_decode($item->aiReport->diagnostic_json ?? '{}'),
            ];
        });

    return response()->json($history);
}

}
