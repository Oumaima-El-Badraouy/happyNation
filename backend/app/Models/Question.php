<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
        protected $fillable = ['text','type','options','order','active'];
        protected $casts = [
            'options' => 'array',
        'active' => 'boolean',
            ];
}
