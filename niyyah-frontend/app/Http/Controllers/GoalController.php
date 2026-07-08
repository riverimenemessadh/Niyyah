<?php
namespace App\Http\Controllers;

use App\Models\Goal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;

class GoalController extends Controller
{
    public function store(Request $request)
    {
        $goal = Goal::create($request->all());
        return response()->json($goal, 201);
    }
}