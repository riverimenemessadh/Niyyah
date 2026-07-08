<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GoalController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    Route::get('/goals',              [GoalController::class, 'index']);
    Route::post('/goals',             [GoalController::class, 'store']);
    Route::put('/goals/{goal}',       [GoalController::class, 'update']);
    Route::delete('/goals/{goal}',    [GoalController::class, 'destroy']);
    Route::post('/goals/{goal}/log',      [GoalController::class, 'log']);
    Route::post('/goals/{goal}/complete', [GoalController::class, 'complete']);

    Route::put('/user', [AuthController::class, 'updateName']);
Route::delete('/user', [AuthController::class, 'deleteAccount']);
    });