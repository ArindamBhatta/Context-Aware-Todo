<?php

// ! 3. The 5 CRUD methods, with validation

namespace App\Http\Controllers;

use App\Models\Todo;
use Illuminate\Http\Request;

// A CONTROLLER receives the HTTP request, does the work, and returns a response.
// This one has the 5 standard CRUD methods:
//
//   Method   URL               Controller method   What it does
//   GET      /api/todos        index()             list all todos     (Read)
//   POST     /api/todos        store()             create a todo      (Create)
//   GET      /api/todos/{id}   show()              get one todo       (Read)
//   PUT      /api/todos/{id}   update()            change a todo      (Update)
//   DELETE   /api/todos/{id}   destroy()           delete a todo      (Delete)
//
// These URLs are connected to the methods in routes/api.php.
class TodoController extends Controller
{
    // READ ALL: GET /api/todos
    public function index()
    {
        // latest() sorts by created_at, newest first. get() runs the query.
        // Returning a model or collection from a controller makes Laravel
        // convert it to JSON automatically.
        return Todo::latest()->get();
    }

    // CREATE: POST /api/todos
    // Laravel puts the incoming request (headers, body, ...) into $request.
    public function store(Request $request)
    {
        // Step 1: VALIDATE the input.
        // If validation fails, Laravel STOPS here and sends a
        // 422 response with the error messages. Your code below never runs.
        // If it passes, $validated holds ONLY the fields listed here.
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'], // must be sent, max 255 characters
            'description' => ['nullable', 'string'],        // optional
            'is_completed' => ['boolean'],                    // optional, must be true/false
        ]);

        // Step 2: SAVE to the database (an INSERT INTO todos ... query).
        $todo = Todo::create($validated);

        // Step 3: RESPOND with the new todo and status 201 ("Created").
        return response()->json($todo, 201);
    }

    // READ ONE: GET /api/todos/{todo}
    //
    // "Route model binding": because the parameter is typed as Todo $todo,
    // Laravel reads the {todo} id from the URL, runs Todo::find(id) for you,
    // and passes in the found row.
    // If there is no row with that id, Laravel automatically returns 404 Not Found.
    public function show(Todo $todo)
    {
        return $todo;
    }

    // UPDATE: PUT or PATCH /api/todos/{todo}
    public function update(Request $request, Todo $todo)
    {
        // Step 1: VALIDATE.
        // 'sometimes' means: only check this field IF it was sent.
        // So you can send just {"is_completed": true} to tick a todo off,
        // without sending the title again.
        $validated = $request->validate([
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string'],
            'is_completed' => ['sometimes', 'boolean'],
        ]);

        // Step 2: SAVE the changes (an UPDATE todos SET ... query).
        // updated_at is refreshed automatically.
        $todo->update($validated);

        // Step 3: RESPOND with the updated todo (status 200 OK by default).
        return $todo;
    }

    // DELETE: DELETE /api/todos/{todo}
    public function destroy(Todo $todo)
    {
        // Remove the row from the database (a DELETE FROM todos ... query).
        $todo->delete();

        // 204 "No Content": success, with nothing to send back.
        return response()->noContent();
    }
}
