<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\ResponseAnswer;
class Response extends Model
{
     protected $fillable = ['user_id'];

    public function answers() {
        return $this->hasMany(ResponseAnswer::class);
    }

    public function aiReport() {
        return $this->hasOne(AiReport::class);
    }

    public function user() {
        return $this->belongsTo(User::class);
    }
}
