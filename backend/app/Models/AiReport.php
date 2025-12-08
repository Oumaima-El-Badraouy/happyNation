<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AiReport extends Model
{
    protected $fillable = ['response_id','diagnostic_json','model'];
   protected $casts = [
    'diagnostic_json' => 'array',
];


    public function response() {
        return $this->belongsTo(Response::class);
    }
}
