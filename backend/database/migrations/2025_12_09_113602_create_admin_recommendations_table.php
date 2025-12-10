<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up()
{
    Schema::create('admin_recommendations', function (Blueprint $table) {
        $table->id();
        $table->foreignId('response_id')->constrained('responses')->onDelete('cascade');
        $table->json('recommendations'); // store array of strings
        $table->timestamps();
    });
}


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin_recommendations');
    }
};
