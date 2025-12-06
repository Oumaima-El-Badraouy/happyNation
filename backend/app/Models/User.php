<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use App\Models\Response;
use Laravel\Passport\HasApiTokens;

class User extends Authenticatable
{
    
    use HasApiTokens, HasFactory, Notifiable;
    /**
 * @method \Laravel\Passport\PersonalAccessTokenResult createToken(string $name, array $scopes = [])
 */
    protected $fillable = ['name','email','password','role'];

    protected $hidden = ['password','remember_token'];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function responses() {
        return $this->hasMany(Response::class);
    }
    
}
