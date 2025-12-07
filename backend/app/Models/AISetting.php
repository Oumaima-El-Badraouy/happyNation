<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AISetting extends Model
{
    protected $table = 'ai_settings';

    protected $fillable = [
        'stress_weight',
        'motivation_weight',
        'satisfaction_weight',
        'risk_levels',
        'model'
    ];

    protected $casts = [
        'risk_levels' => 'array',
    ];
}
