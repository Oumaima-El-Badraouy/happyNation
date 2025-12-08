<?php
namespace App\Http\Controllers\API;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Frequency;
use Illuminate\Support\Facades\Auth;

class FrequencyController extends Controller
{
     public function index()
    {
        $frequency = Frequency::all();
        
        return response()->json($frequency);
    }

    public function update(Request $request, $id)
    {
        $user = Auth::user();
        if ($user->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $frequencys = Frequency::findOrFail($id);
        $request->validate([
            'frequency' => 'required|enum["daily", "weekly", "monthly"]',
        ]);

        $frequencys->update($request->all());
        return response()->json($frequencys);
    }
}
