<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('ai_settings', function (Blueprint $table) {
            $table->id();
            $table->float('stress_weight')->default(1);
            $table->float('motivation_weight')->default(1);
            $table->float('satisfaction_weight')->default(1);
            $table->json('risk_levels')->nullable(); // ex: {"low":0-30,"medium":31-70,"high":71-100}
            $table->string('model')->default('gemini-2.0-flash');
            $table->timestamps();
        });

        // Create a default row
        DB::table('ai_settings')->insert([
            'stress_weight' => 1,
            'motivation_weight' => 1,
            'satisfaction_weight' => 1,
            'risk_levels' => json_encode([
                "low" => "0-30",
                "medium" => "31-70",
                "high" => "71-100"
            ]),
            'model' => 'gemini-2.0-flash',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_settings');
    }
};
