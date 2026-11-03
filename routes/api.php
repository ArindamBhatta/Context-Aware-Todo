<?php

// ! 4. Connects the URLs to the controller
use App\Http\Controllers\TodoController;
use Illuminate\Support\Facades\Route;

// ROUTES connect a URL + HTTP method to a controller method.
// Every route in THIS file automatically starts with "/api"
// (so 'todos' below becomes http://127.0.0.1:8000/api/todos).

// apiResource() is a shortcut that creates all 5 CRUD routes in one line.
// It is the same as writing these out by hand:
//
//   Route::get('/todos', [TodoController::class, 'index']);
//   Route::post('/todos', [TodoController::class, 'store']);
//   Route::get('/todos/{todo}', [TodoController::class, 'show']);
//   Route::put('/todos/{todo}', [TodoController::class, 'update']);    // PATCH works too
//   Route::delete('/todos/{todo}', [TodoController::class, 'destroy']);
//
// Run `php artisan route:list` in the terminal to see them all.
Route::apiResource('todos', TodoController::class);
