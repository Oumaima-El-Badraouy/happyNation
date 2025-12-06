<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;

// ===========================
// Routes for AuthController
// ===========================
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:api')->group(function () {
    Route::post('/register', [AuthController::class, 'register']); // خاص admin
    Route::post('/logout', [AuthController::class, 'logout']);
});
