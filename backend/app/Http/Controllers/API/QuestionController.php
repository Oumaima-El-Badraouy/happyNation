<?php

namespace App\Http\Controllers\API;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Question;
use App\Models\Frequency;
use Carbon\Carbon;
class QuestionController extends Controller
{
    // ===========================
    // List all questions
    // ===========================


public function index()
{
    $user = Auth::user();

    // 1) Get frequency (supposons qu'il y a 1 row seulement)
    $frequency = Frequency::first();
    if(!$frequency) {
        return response()->json(['message' => 'Frequency not set'], 400);
    }

    $today = Carbon::now();
    $showQuestions = false;

    // 2) Check if today matches frequency
    switch($frequency->frequency) {
        case 'daily':
            $showQuestions = true; // every day
            break;
        case 'weekly':
            // Par exemple chaque lundi
            if($today->isMonday()) {
                $showQuestions = true;
            }
            break;
        case 'monthly':
            // Par exemple 1er du mois
            if($today->day == 1) {
                $showQuestions = true;
            }
            break;
    }

    // 3) Return questions si frequency match
    if($showQuestions) {
        $questions = Question::where('active', true)
            ->orderBy('order')
            ->get();
        return response()->json($questions);
    }

    // 4) Sinon return message
    return response()->json([
        'message' => 'Pas de questionnaire pour aujourd’hui'
    ]);
}
public function indexAdmin()
{
    $user = Auth::user();
if ($user->role !== 'admin') {
        return response()->json(['message' => 'Unauthorized'], 403);
    }
        $questions = Question::all();
        return response()->json($questions);
}


    // ===========================
    // Create a new question
    // ===========================
    public function store(Request $request)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'text' => 'required|string',
            'type' => 'nullable|string',
            'options' => 'nullable|array',
            'order' => 'nullable|integer',
            'active' => 'nullable|boolean',
        ]);

        $question = Question::create($request->all());
        return response()->json($question, 201);
    }

    public function details($id)
{
    $user = Auth::user();
    if ($user->role !== 'admin') {
        return response()->json(['message' => 'Unauthorized'], 403);
    }

    // Get question
    $question = Question::findOrFail($id);

    return response()->json([
        'id'        => $question->id,
        'text'      => $question->text,
        'type'      => $question->type,
        'options'   => $question->options,   // array
        'order'     => $question->order,
        'active'    => $question->active,
        'created_at'=> $question->created_at->format('Y-m-d H:i'),
        'updated_at'=> $question->updated_at->format('Y-m-d H:i'),
    ]);
}

    // ===========================
    // Show a single question
    // ===========================
    public function show($id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $question = Question::findOrFail($id);
        return response()->json($question);
    }

    // ===========================
    // Update a question
    // ===========================
    public function update(Request $request, $id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $question = Question::findOrFail($id);

        $request->validate([
            'text' => 'sometimes|required|string',
            'type' => 'sometimes|string',
            'options' => 'sometimes|array',
            'order' => 'sometimes|integer',
            'active' => 'sometimes|boolean',
        ]);

        $question->update($request->all());
        return response()->json($question);
    }

    // ===========================
    // Delete a question
    // ===========================
    public function destroy($id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $question = Question::findOrFail($id);
        $question->delete();

        return response()->json(['message' => 'Question deleted']);
    }
}
