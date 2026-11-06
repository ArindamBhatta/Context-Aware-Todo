<?php

// ! 1: Defines the Migration table

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
            $table->uuid('id')->primary();

            $table->string('name');

            $table->text('description')->nullable();

            $table->string('category');

            $table->boolean('is_pending')->default(true);

            $table->string(('task_type'));

            $table->string(('urgency_level'));

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
