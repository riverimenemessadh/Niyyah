<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('goals', function (Blueprint $table) {
            $table->id();

            // Links each goal to a user — we'll use this later
            $table->foreignId('user_id')->constrained()->onDelete('cascade');

            $table->string('title');
            $table->text('description')->nullable();

            // e.g. "Quran", "Prayer", "Learning", "Other"
            $table->string('category');

            // e.g. 30 days, 20 pages
            $table->integer('target_value')->nullable()->default(0);

            // How far the user has progressed
            $table->integer('current_progress')->default(0);

            $table->date('deadline')->nullable();
            $table->boolean('is_completed')->default(false);

            $table->timestamps(); // creates created_at and updated_at automatically
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('goals');
    }
};