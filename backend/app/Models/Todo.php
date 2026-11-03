<?php

// ! 2. The model that talks to the todos table

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

// A MODEL is a PHP class that represents ONE table in the database.
// Laravel guesses the table name from the class name:
//   class "Todo"  ->  table "todos"   (lowercase + plural)
//
// Extending Model gives you all the database methods for free, for example:
//   .Todo::all()                 -> get every row
//   .Todo::find(1)               -> get the row with id = 1
//   .Todo::create([...])         -> insert a new row
//   $todo->update([...])        -> change a row
//   $todo->delete()             -> remove a row

// #[Fillable] is a security list: only these columns may be set in bulk
// with Todo::create($data) or $todo->update($data).
// Anything else in $data (for example "id") is silently ignored, so a user
// can't overwrite columns they shouldn't touch. This is "mass assignment" protection.
#[Fillable(['title', 'description', 'is_completed'])]
class Todo extends Model
{
    // DEFAULT VALUES for a new Todo object, before it is saved.
    // The migration already sets default(false) in the DATABASE, but PHP doesn't
    // know about it. Without this line, the JSON returned right after
    // .Todo::create() would leave out "is_completed".
    protected $attributes = [
        'is_completed' => false,
    ];

    // CASTS convert database values into proper PHP types.
    // SQLite/MySQL store booleans as 1 or 0. This cast turns them into
    // true/false, so your JSON shows "is_completed": true instead of 1.
    protected function casts(): array
    {
        return [
            'is_completed' => 'boolean',
        ];
    }
}
