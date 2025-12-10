<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\QuestionController;
use App\Http\Controllers\API\AdminController;
use App\Http\Controllers\API\ResponseController;
use App\Http\Controllers\API\AIConfigController;
use App\Http\Controllers\API\StatisticsController;
use App\Http\Controllers\API\FrequencyController;

// ===========================
// Routes for AuthController
// ===========================
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:api')->group(function () {
    Route::post('/register', action: [AuthController::class, 'register']); // خاص admin
    Route::post('/logout', [AuthController::class, 'logout']);

});
Route::middleware('auth:api')->group(function() {
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me/update', [AuthController::class, 'update']);
});

Route::middleware('auth:api')->group(function () {
    Route::get('/questions', [QuestionController::class, 'index']);
    Route::get('/Admin/questions',[QuestionController::class, 'indexAdmin']);
    Route::get('/questions/{id}', [QuestionController::class, 'show']);
    Route::post('/questions', [QuestionController::class, 'store']);
    Route::put('/questions/{id}', [QuestionController::class, 'update']);
    Route::delete('/questions/{id}', [QuestionController::class, 'destroy']);
});



Route::middleware('auth:api')->group(function () {
    Route::get('/users', [AdminController::class, 'index']); // list all users
    Route::get('/users/{id}', [AdminController::class, 'show']); // show single user
    Route::put('/users/{id}', [AdminController::class, 'update']); // update user
    Route::delete('/users/{id}', [AdminController::class, 'destroy']); // delete user
});

Route::middleware('auth:api')->group(function () {
    Route::post('/responses', [ResponseController::class, 'store']);
    Route::get('/responses/history', [ResponseController::class, 'history']);
});

Route::middleware(['auth:api'])->group(function () {
    Route::get('/admin/ai-settings', [AIConfigController::class, 'getSettings']);
    Route::post('/admin/ai-settings', [AIConfigController::class, 'updateSettings']);
});

Route::middleware(['auth:api'])->group(function () {
    Route::get('/admin/statistics/global', [StatisticsController::class, 'globalStats']);
});

Route::middleware(['auth:api'])->group(function () {
    Route::get('/frequencies', [FrequencyController::class, 'index']);
    Route::put('/frequencies', [FrequencyController::class, 'update']);
});
