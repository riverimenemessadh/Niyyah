<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Goal extends Model
{
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'type',
        'category',
        'target_value',
        'current_progress',
        'deadline',
        'is_completed',
        'last_logged_date',
    ];

    protected $casts = [
        'is_completed' => 'boolean',
        'deadline'     => 'date',
        'target_value' => 'integer',
        'current_progress' => 'integer',
        'last_logged_date' => 'string',
    ];
}