<?php

// ! 1: Defines the todos table

// A MIGRATION describes the structure of a database table, written in PHP.
// Run `php artisan migrate` to create the table.
// Run `php artisan migrate:rollback` to undo it (this calls down()).

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // up() runs when you migrate: it CREATES the "todos" table.
    public function up(): void
    {
        Schema::create('todos', function (Blueprint $table) {
            // Auto-incrementing primary key column called "id" (1, 2, 3, ...).
            $table->id();

            // VARCHAR(255) column for the todo's title. It is required (NOT NULL).
            $table->string('title');

            // TEXT column for a longer description. nullable() makes it optional.
            $table->text('description')->nullable();

            // TRUE/FALSE column. New todos start as "not completed".
            $table->boolean('is_completed')->default(false);

            // Adds two columns, "created_at" and "updated_at".
            // Laravel fills them in automatically on create and update.
            $table->timestamps();
        });
    }

    // down() runs when you roll back: it DELETES the table, undoing up().
    public function down(): void
    {
        Schema::dropIfExists('todos');
    }
};
