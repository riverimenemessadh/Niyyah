<?php

namespace App\Http\Controllers;

use App\Models\Goal;
use Illuminate\Http\Request;

class GoalController extends Controller
{
    public function index(Request $request)
    {
        $goals = $request->user()->goals()->latest()->get();
        return response()->json($goals);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title'            => 'required|string|max:255',
            'description'      => 'nullable|string|max:150',
            'type'             => 'required|in:habit,goal',
            'category'         => 'required|in:Salah,Quran,Fasting,Dhikr,Sadaqah,Sunnah,Dua,Tawbah,Other',
            'target_value'     => 'nullable|integer|min:1',
            'deadline'         => 'nullable|date',
        ]);

        $data['user_id'] = $request->user()->id;
        $data['current_progress'] = 0;
        $data['is_completed'] = false;

        $goal = Goal::create($data);
        return response()->json($goal, 201);
    }

    public function update(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'title'        => 'sometimes|string|max:255',
            'description'  => 'nullable|string|max:150',
            'type'         => 'sometimes|in:habit,goal',
            'category'     => 'sometimes|in:Salah,Quran,Fasting,Dhikr,Sadaqah,Sunnah,Dua,Tawbah,Other',
            'target_value' => 'nullable|integer|min:1',
            'deadline'     => 'nullable|date',
            'is_completed' => 'sometimes|boolean',
        ]);

        $goal->update($data);
        return response()->json($goal);
    }

    public function destroy(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $goal->delete();
        return response()->json(['message' => 'Deleted']);
    }

    public function log(Request $request, $id)
{
    $goal = Goal::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->firstOrFail();

    if ($goal->type !== 'habit') {
        return response()->json(['message' => 'Only habits can be logged.'], 422);
    }

    $today = now()->toDateString();

    // If last_logged_date is set AND it equals today, block the log
    if ($goal->last_logged_date !== null) {
        $lastLogged = \Carbon\Carbon::parse($goal->last_logged_date)->toDateString();
        if ($lastLogged === $today) {
            return response()->json([
                'message'  => 'Already logged today.',
                'goal'     => $goal,          // <-- always return the full goal
            ], 409);
        }
    }

    $goal->current_progress += 1;
    $goal->last_logged_date  = $today;
    $goal->save();

    return response()->json(['goal' => $goal], 200);
}

    public function complete(Request $request, Goal $goal)
    {
        if ($goal->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        if ($goal->type !== 'goal') {
            return response()->json(['message' => 'Only goals can be marked complete'], 422);
        }

        $goal->update(['is_completed' => true]);
        return response()->json($goal->fresh());
    }
}