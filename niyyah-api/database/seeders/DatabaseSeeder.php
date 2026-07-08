<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Goal;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ── User 1: Yusuf ──────────────────────────────────────────
        $yusuf = User::create([
            'name'     => 'Yusuf Al-Amin',
            'email'    => 'yusuf@niyyah.app',
            'password' => Hash::make('password'),
        ]);

        // Habits — have streaks going
        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Pray all 5 daily prayers',
            'description'      => 'Never miss a single salah, even when travelling',
            'type'             => 'habit',
            'category'         => 'Salah',
            'target_value'     => 30,
            'current_progress' => 14,
            'deadline'         => null,
            'is_completed'     => false,
            'last_logged_date' => now()->subDay()->toDateString(),
        ]);

        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Read 1 page of Quran after Fajr',
            'description'      => 'Consistency over quantity — one page every morning',
            'type'             => 'habit',
            'category'         => 'Quran',
            'target_value'     => 60,
            'current_progress' => 22,
            'deadline'         => null,
            'is_completed'     => false,
            'last_logged_date' => now()->subDay()->toDateString(),
        ]);

        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Say 100 Subhanallah after Asr',
            'description'      => 'Morning and evening adhkar habit',
            'type'             => 'habit',
            'category'         => 'Dhikr',
            'target_value'     => 30,
            'current_progress' => 7,
            'deadline'         => null,
            'is_completed'     => false,
            'last_logged_date' => now()->toDateString(), // already logged today
        ]);

        // Goals — mix of completed and active
        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Memorise Surah Al-Mulk',
            'description'      => 'Complete memorisation with proper tajweed',
            'type'             => 'goal',
            'category'         => 'Quran',
            'target_value'     => 0,
            'current_progress' => 0,
            'deadline'         => now()->addMonths(2)->toDateString(),
            'is_completed'     => false,
            'last_logged_date' => null,
        ]);

        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Fast Mondays and Thursdays for a month',
            'description'      => 'Sunnah fasting — the Prophet fasted these days',
            'type'             => 'goal',
            'category'         => 'Fasting',
            'target_value'     => 0,
            'current_progress' => 0,
            'deadline'         => now()->addMonth()->toDateString(),
            'is_completed'     => false,
            'last_logged_date' => null,
        ]);

        Goal::create([
            'user_id'          => $yusuf->id,
            'title'            => 'Give Sadaqah every Friday',
            'description'      => 'Even a small amount — consistency matters',
            'type'             => 'goal',
            'category'         => 'Sadaqah',
            'target_value'     => 0,
            'current_progress' => 0,
            'deadline'         => null,
            'is_completed'     => true, // completed goal example
            'last_logged_date' => null,
        ]);

        // ── User 2: Fatima ─────────────────────────────────────────
        $fatima = User::create([
            'name'     => 'Fatima Zahra',
            'email'    => 'fatima@niyyah.app',
            'password' => Hash::make('password'),
        ]);

        Goal::create([
            'user_id'          => $fatima->id,
            'title'            => 'Pray Qiyam al-Layl on Fridays',
            'description'      => 'Wake up last third of the night to pray',
            'type'             => 'habit',
            'category'         => 'Salah',
            'target_value'     => 10,
            'current_progress' => 3,
            'deadline'         => null,
            'is_completed'     => false,
            'last_logged_date' => now()->subDays(2)->toDateString(),
        ]);

        Goal::create([
            'user_id'          => $fatima->id,
            'title'            => 'Make dua after every salah',
            'description'      => 'Take 5 minutes after each prayer for personal dua',
            'type'             => 'habit',
            'category'         => 'Dua',
            'target_value'     => 21,
            'current_progress' => 9,
            'deadline'         => null,
            'is_completed'     => false,
            'last_logged_date' => now()->subDay()->toDateString(),
        ]);

        Goal::create([
            'user_id'          => $fatima->id,
            'title'            => 'Complete Tawbah and write a sincere letter to Allah',
            'description'      => 'A personal act of repentance and renewal of faith',
            'type'             => 'goal',
            'category'         => 'Tawbah',
            'target_value'     => 0,
            'current_progress' => 0,
            'deadline'         => now()->addWeeks(2)->toDateString(),
            'is_completed'     => false,
            'last_logged_date' => null,
        ]);

        Goal::create([
            'user_id'          => $fatima->id,
            'title'            => 'Learn the meaning of Al-Fatiha in Arabic',
            'description'      => 'Understand every word of the opening surah',
            'type'             => 'goal',
            'category'         => 'Quran',
            'target_value'     => 0,
            'current_progress' => 0,
            'deadline'         => null,
            'is_completed'     => true,
            'last_logged_date' => null,
        ]);
    }
}