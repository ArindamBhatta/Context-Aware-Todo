<?php

// ! 2. The model that talks to the todos table (Eloquent ORM). This is the "M" in MVC.

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use App\Enums\Category;
use App\Enums\TaskType;
use App\Enums\UrgencyLevel;

#[Fillable(['name', 'description', 'category', 'is_pending', 'task_type', 'urgency_level'])] // what fields not to guard against mass assignment
class Todo extends Model //Eloquent 
{

    protected $attributes = [
        'is_completed' => false,
    ];

    // CASTS convert database values into proper PHP types.
    // SQLite/MySQL store booleans as 1 or 0. This cast turns them into
    // true/false, so your JSON shows "is_completed": true instead of 1.
    protected function casts(): array
    {
        return [
            'category' => Category::class,
            'task_type' => TaskType::class,
            'urgency_level' => UrgencyLevel::class,
            'is_pending' => 'boolean',
            ];
    }
}
