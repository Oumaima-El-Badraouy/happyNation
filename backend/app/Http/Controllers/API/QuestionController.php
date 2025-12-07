<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Question;

class QuestionController extends Controller
{
    // ===========================
    // List all questions
    // ===========================
    public function index()
    {
        $user = Auth::user();
        $questions = Question::where('active', true)->orderBy('order')->get();
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
