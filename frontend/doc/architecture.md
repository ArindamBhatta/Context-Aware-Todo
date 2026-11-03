# Todo App — Architecture & Coding Instructions

This document describes the intended architecture for the **todo** app.
It is based on Flutter’s official app-architecture guidance:

- Guide: https://docs.flutter.dev/app-architecture/guide
- Design patterns: https://docs.flutter.dev/app-architecture/design-patterns
- Recommendations: https://docs.flutter.dev/app-architecture/recommendations

The repo uses **Cubit**  for UI logic and state.
In Flutter’s MVVM terms, you can treat a **Cubit Notifier as the ViewModel**.

---

## 1) Non-negotiable principles

### Separation of concerns (strongly recommended)
- **Widgets are “dumb”**: UI code should render state and forward user intent.
- **UI logic lives outside widgets** (in Cubits).
- **Business/data logic lives in repositories**.
- **I/O lives in services/datasources**.

### Unidirectional data flow (strongly recommended)
- Data flows **Data layer → UI layer** as states/streams.
- User interactions flow **UI layer → Data layer** as method calls / commands on providers.

### Dependency direction (strongly recommended)
- UI depends on providers/notifiers (and optionally domain/use-cases).
- Cubits depend on repositories.
- Repositories depend on datasources/services.
- Services depend on external APIs (SQLite, etc.).
- Avoid circular dependencies and cross-feature “reach-ins”.

---

## 2) Layer mapping (Flutter MVVM ↔ this repo)

Flutter architecture guide recommends:

- **View**: Widgets/screens
- **ViewModel**: A testable UI-logic class (Riverpod Notifier)
- **Repository**: Source of truth for application data
- **Service/Datasource**: Stateless wrapper around an external data source
- **(Optional) Domain layer**: Use-cases/interactors for complex reusable logic

In this repo:

- **View** → `lib/features/<feature>/presentation/page/*` (and `presentation/widgets/*`)
- **ViewModel** → `lib/features/<feature>/presentation/logic/*` (Cubit notifiers/providers)
- **Repository** → `lib/data/` (or `lib/features/<feature>/data/repositories/*` for feature-specific repos)
- **Service/Datasource** → `lib/data/` (or `lib/features/<feature>/data/datasources/*` for local/remote services)
- **Domain layer (optional)** → `lib/features/<feature>/domain/*_usecase.dart`

---

## 3) Project structure conventions

### Top level
- `lib/main.dart` is the **composition root** (app setup wrapped in `BlocProvider` + dependency wiring).
- `lib/core/` contains cross-cutting utilities and shared UI widgets (like `scrollable_tab_bar.dart`).
- `lib/features/<feature_name>/` is the unit of modularity.

### Feature-first layout
Each feature should generally follow:

```
lib/features/<feature>/
  data/                      (optional if feature-specific)
    datasources/
      <something>_service.dart
    models/
      <something>_dto.dart (or *_model.dart)
    repositories/
      <feature>_repository.dart
  domain/                    (optional)
    <use_case>.dart
  presentation/
    logic/
      <feature>_manager.dart  (Cubit Notifiers & providers)
    page/
      <feature>_page.dart (or *_screen.dart)
    widgets/
      ...
```

Notes:
- Some features (like `home`) might not have all folders initially; that’s fine.
- Global data models and databases (e.g., `lib/data/todo.dart`, `todo_database.dart`, and `todo_repository.dart`) are kept in the shared data folder, while feature-specific data goes inside `lib/features/<feature>/data/`.

---

## 4) UI layer rules (Views + Riverpod Providers)

### Views (widgets/pages)
Views should contain only:
- Layout and styling.
- Simple branching (`if`/`switch` or Cubit's `emit()` method) to show/hide UI based on state.
- Animation logic.
- Basic routing calls (`Navigator.*` or a routing abstraction like `go_router`).

Views should NOT:
- Parse JSON or handle raw model mapping.
- Call databases or HTTP clients directly.
- Maintain complex business/caching state.

### Riverpod Notifier responsibilities
A Notifier should:
- Translate user intent (method calls) into state transitions.
- Orchestrate calls to repositories/use-cases.
- Map repository results/errors into UI state (e.g., using `AsyncValue`).

Guidelines:
- Keep states **immutable** (use `copyWith` for models).
- Prefer **explicit async states** (using `AsyncValue` like `AsyncLoading`, `AsyncData`, and `AsyncError`) over ad-hoc boolean loading flags.
- Don’t call services/databases directly from Notifiers; go through repositories.

---

## 5) Data layer rules (Repositories + Services)

### Services/Datasources (lowest level)
Services should:
- Be **stateless** wrappers for external I/O (SQLite, SharedPreferences, APIs).
- Return `Future`/`Stream` results.
- Know *how* to talk to the API or DB, not *what the app needs*.

### Repositories (source of truth)
Repositories should:
- Expose app-usable data models to the rest of the app.
- Handle caching, refresh, retries, and database query executions.
- Support platform-specific strategies (e.g., SQLite for mobile/native, and SharedPreferences fallback for web).

---

## 6) Domain layer (use-cases) — when to add it

A domain/use-case is optional. Add one when logic:
- Merges data from multiple repositories.
- Is complex enough to clutter the Notifier.
- Is reused by multiple view-models/notifiers.

---

## 7) Dependency Injection (DI)

Riverpod is used as the dependency injection system in this codebase.

In this repo:
- Use stateless `Provider` to expose repositories or services (e.g., `todoRepositoryProvider`).
- Use `AsyncNotifierProvider` / `NotifierProvider` for stateful UI logic (e.g., `taskListProvider`).
- Read dependencies using `ref.read` (inside Notifier initialization or callback events) and watch them using `ref.watch` (for UI rebuilds).

Testing benefit:
- You can override providers in unit and widget tests using `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.

---

## 8) Navigation

Flutter recommends `go_router` for navigation.

Current status:
- `go_router` is listed as a dependency, but navigation is currently driven via `MaterialApp(home: ...)` switching indexes in `OnBoardingPage`.
- Guarded routes or deep links should utilize `go_router`.

---

## 9) Data models and immutability

- Prefer **immutable data models** using `final` fields.
- Avoid mutating models after creation; use `copyWith()` for updates.

---

## 10) Testing expectations

Unit and Widget tests should test components in isolation:
- **Unit tests**:
  - Repositories: local persistence caching and fallback logic.
  - Riverpod Notifiers: verify correct state sequences (e.g., loading → success) when methods are called using a `ProviderContainer`.
- **Widget tests**:
  - Views render correct UI based on provider states (e.g., rendering list items for `AsyncData` or a circular progress indicator for `AsyncLoading`).

---

## 11) How to add a new feature (checklist)

1. Create the feature folder under `lib/features/<feature>/`.
2. Add the UI layout inside `presentation/page/` and custom components inside `presentation/widgets/`.
3. Add a Riverpod notifier inside `presentation/logic/`:
   - Extend `AsyncNotifier` or `Notifier`.
   - Expose the provider globally (e.g., `final featureListProvider = AsyncNotifierProvider<...>(...)`).
4. Set up repositories and services under `lib/data/` (or `lib/features/<feature>/data/`).
5. Wire DI by reading/watching the repository provider inside the notifier using `ref.read`.
6. Add unit and widget tests.

---

## 12) Import and naming conventions

### Naming
- Files/folders: `snake_case`
- Providers/Notifiers: `<feature>_manager.dart` or `<feature>_provider.dart`
- Repository: `<feature>_repository.dart`
- Pages/Screens: `<feature>_screen.dart` or `<feature>_page.dart`

### Imports
- Inside a feature: prefer **relative imports** for nearby files.
- Across features / from core: prefer package-level imports (e.g., `package:todo/...`).