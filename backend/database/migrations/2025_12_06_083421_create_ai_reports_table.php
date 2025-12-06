<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ai_reports', function (Blueprint $table) {
            $table->id();
    $table->foreignId('response_id')->constrained()->cascadeOnDelete();
    $table->json('diagnostic_json');
    $table->string('model')->nullable();
    $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_reports');
    }
};
