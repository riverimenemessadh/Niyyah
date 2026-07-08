<div align="center">

# Niyyah (نيّة)

An Islamic personal habits & goals planner. Track daily worship habits with streaks, set one-time spiritual goals, and stay consistent — built with Flutter and Laravel.

![Demo](demo.png)

</div>

---

## Overview

Niyyah helps Muslims track two kinds of worship commitments: **habits** (recurring actions like daily prayers or Quran recitation, tracked with a streak counter) and **goals** (one-time objectives, marked done when complete). Everything is organized by category — Salah, Quran, Fasting, Dhikr, Sadaqah, Sunnah, Dua, Tawbah — with a clean, calm interface inspired by Islamic geometric patterns and mosque silhouettes.

## Features

- **Habits vs. Goals** — recurring streak-based habits and one-time binary goals, handled with distinct logic and UI
- **Streak tracking** — one-tap daily logging, with duplicate-log prevention for the same day
- **Category system** — 9 worship categories with dedicated icons and color coding
- **Optional deadlines** — goals and habits can have a deadline or none at all
- **Token-based auth** — secure login via Laravel Sanctum, persisted with encrypted local storage
- **Custom-drawn Islamic UI** — hand-built mosque silhouette, geometric star pattern, and illustrated empty states — no image assets
- **Search & filter** — filter goals/habits by type and category

## Tech Stack

**Frontend**

![Flutter](https://img.shields.io/badge/Flutter-3E325A?style=for-the-badge&logo=flutter&logoColor=E8E5F0)
![Dart](https://img.shields.io/badge/Dart-3E325A?style=for-the-badge&logo=dart&logoColor=E8E5F0)

**Backend**

![Laravel](https://img.shields.io/badge/Laravel-3E325A?style=for-the-badge&logo=laravel&logoColor=E8E5F0)
![PHP](https://img.shields.io/badge/PHP-3E325A?style=for-the-badge&logo=php&logoColor=E8E5F0)
![MySQL](https://img.shields.io/badge/MySQL-3E325A?style=for-the-badge&logo=mysql&logoColor=E8E5F0)

**Key packages:** `flutter_secure_storage`, `iconsax`, `google_fonts`, Laravel Sanctum

## Architecture

```
niyyah/
├── flutter_app/
│   └── lib/
│       ├── core/theme.dart         — colors, typography, shared decoration
│       ├── models/goal.dart
│       ├── services/               — api_client, auth_service, goal_service
│       ├── screens/                — login, register, home, goals list/detail, create/edit
│       └── widgets/                — mosque_silhouette, islamic_pattern, empty_state
└── laravel_api/
    ├── routes/api.php
    ├── app/Models/                 — User, Goal
    ├── app/Http/Controllers/       — AuthController, GoalController
    └── database/migrations/
```

Auth is token-based via Sanctum — the Flutter app stores the token with `flutter_secure_storage` and attaches it as a Bearer token on every protected request.

## Design System

- **Primary palette:** deep teal `#1A7A6E`, dark teal `#14584F`, gold accent `#D4A843`
- **Typography:** Nunito for UI text, Amiri for the Arabic app name accent
- Custom `CustomPainter` widgets for the mosque skyline silhouette and subtle 8-pointed star geometric texture — no external image assets

## API Reference

Base URL: `http://127.0.0.1:8000/api`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/register` | — | Create account |
| POST | `/login` | — | Get auth token |
| POST | `/logout` | ✓ | Invalidate token |
| GET | `/me` | ✓ | Current user |
| GET | `/goals` | ✓ | List all habits/goals |
| POST | `/goals` | ✓ | Create habit or goal |
| PUT | `/goals/{id}` | ✓ | Update |
| DELETE | `/goals/{id}` | ✓ | Delete |
| POST | `/goals/{id}/log` | ✓ | Log today for a habit (+1 streak) |
| POST | `/goals/{id}/complete` | ✓ | Mark a goal complete |

## Getting Started

**Backend (Laravel):**
```bash
cd laravel_api
composer install
cp .env.example .env
php artisan key:generate
```
Configure your MySQL credentials in `.env`, then:
```bash
php artisan migrate
php artisan serve
```
API runs at `http://127.0.0.1:8000`.

**Frontend (Flutter):**
```bash
cd flutter_app
flutter pub get
flutter run
```

## Contact

- [Portfolio](https://rivermessadhportfolio.netlify.app/)
- [LinkedIn](https://www.linkedin.com/in/river-messadh)
- [Upwork](https://www.upwork.com/freelancers/~017d459f20e3d30e04)
- [Email](mailto:sarahimenemessadh@gmail.com)
