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
    'stress_weight' => 'float',
    'motivation_weight' => 'float',
    'satisfaction_weight' => 'float',
     'risk_levels' => 'array',
];

}
