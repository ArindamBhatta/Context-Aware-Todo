# 📍 Context-Aware To-Do App

An **intelligent, location-aware, and context-driven personal productivity engine**. It surfaces the right tasks at the right time and place instead of showing one static list.

$$\text{Actionable Task} = \text{Current Location (Geofencing)} + \text{Time and Urgency} + \text{User Focus State}$$

## layout

| Folder | Stack | Purpose |
|---|---|---|
| [`backend/`](backend/) | Laravel (PHP 8.3), Eloquent, SQLite/MySQL | REST API at `/api/todos` |
| [`frontend/`](frontend/) | Flutter, `flutter_bloc`, `sqflite` | Offline-first mobile app |

## Features

* **Geofencing & location awareness**: surface tasks relevant to Office, Home, Gym, etc.
* **Pomodoro focus engine**: focus / short break / long break timers with local notifications.
* **Encrypted biometric vault**: fingerprint / Face ID via `local_auth`, secrets in `flutter_secure_storage`.
* **Quick Work vs. Project Work**: micro-tasks and deadline-driven milestones with urgency levels.
* **Offline-first**: local SQLite cache (`todo_cache.db`), synced to the Laravel API when online.

## Getting started

### Backend (Laravel)

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve --host=0.0.0.0   # http://127.0.0.1:8000
```

API routes (`php artisan route:list`):

| Method | URL | Action |
|---|---|---|
| GET | `/api/todos` | list todos |
| POST | `/api/todos` | create a todo |
| GET | `/api/todos/{id}` | show a todo |
| PUT/PATCH | `/api/todos/{id}` | update a todo |
| DELETE | `/api/todos/{id}` | delete a todo |

Task categories are defined by the `App\Enums\Category` enum and validated with `Rule::enum`.

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

The app calls `http://10.0.2.2:8000/api` by default (Android emulator → host machine). For a physical device:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-machine-ip>:8000/api
```

See [`frontend/README.md`](frontend/README.md) for the Flutter-specific details and demo screenshots.
