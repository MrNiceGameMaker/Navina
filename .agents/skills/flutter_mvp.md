---
name: flutter_mvp
description: >
  Workspace coding standards for the Navina Onboarding Flutter Web project.
  Enforces strict no-comment, geometric UI, and Riverpod state management rules
  for all generated Dart files.
---

# Navina Onboarding — Flutter MVP Workspace Rules

## Rule 1: Zero Comments

No `//` single-line comments and no `/* */` block comments are permitted in any Dart file.
This applies to every file in the `lib/` directory without exception.
Violations will be rejected at QA review.

## Rule 2: Flat, Geometric, High-Contrast UI

Every UI component must conform to the following design system:

- **Border Radius**: Always `BorderRadius.zero`. Never use rounded corners.
- **Elevation**: Always `0`. Never use shadows or depth.
- **Primary Color**: `Colors.black` (`#000000`).
- **Scaffold Background**: `Color(0xFFF4F4F9)`.
- **Text Direction**: `TextDirection.rtl` — all `Scaffold` bodies must be wrapped in a `Directionality` widget set to RTL.
- **Button Style**: `ElevatedButton` uses black fill, white text, `BorderRadius.zero`, elevation 0.
- **Input Borders**: `OutlineInputBorder` with `BorderRadius.zero` and `BorderSide(color: Colors.black)`.
- **Dividers**: `DividerThemeData(color: Colors.black, thickness: 1, space: 0)`.
- **Cards**: `CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero))`.

## Rule 3: Riverpod State Management

All state management uses `flutter_riverpod`. The following conventions are mandatory:

- Expose the `SupabaseClient` through a root `Provider<SupabaseClient>` defined in `lib/core/network/supabase_providers.dart`.
- Repository classes receive a `SupabaseClient` via constructor injection; they are exposed by a `Provider<Repository>`.
- Async data lists use `FutureProvider` or `AsyncNotifierProvider`.
- Single-entity state with mutations uses `StateNotifier` wrapped in `StateNotifierProvider`.
- Family providers use `.family` modifier with typed arguments (e.g., `String` for `employee_id`).
- No `StatefulWidget` is used for state that belongs in a provider.

## Rule 4: Clean Architecture — Feature-First

Directory structure:
```
lib/
  core/
    network/       ← Supabase client provider
    theme/         ← ThemeData definition (no inline theme in main.dart in future phases)
  features/
    hr_dashboard/
      data/
        models/
        repositories/
      presentation/
        views/
        view_models/
    employee_view/
      data/
        models/
        repositories/
      presentation/
        views/
        view_models/
  models/          ← Shared cross-feature data models
```

All models define `fromJson(Map<String, dynamic>)` factory constructors and `toJson()` methods.
