# Navina Onboarding Platform

A production-grade employee onboarding system built with **Flutter 3**, **Riverpod 3**, and **Supabase**, designed for simultaneous multi-device use. The platform provides HR managers with a dynamic employee creation workflow and each employee with a personalized, real-time task dashboard assisted by a RAG-enabled Gemini AI assistant.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Feature Modules](#feature-modules)
- [Data Model](#data-model)
- [State Management](#state-management)
- [Real-Time Synchronization](#real-time-synchronization)
- [AI Assistant — RAG Pipeline](#ai-assistant--rag-pipeline)
- [Supabase Schema](#supabase-schema)
- [Environment Setup](#environment-setup)
- [Running the App](#running-the-app)
- [Design System](#design-system)

---

## Overview

Navina Onboarding replaces static onboarding checklists with a dynamic, cloud-native platform. HR creates an employee record and selects their exact role, required documents, equipment, and scheduled meetings. The system performs a bulk insert of the resulting tasks into Supabase, and every device watching that employee's data refreshes automatically via WebSocket-based Postgres Realtime subscriptions — no polling required.

---

## Architecture

The project follows a **vertical slice** structure. Each feature owns its own presentation layer, view models, and data access. Shared infrastructure (network, models, providers) lives under `lib/core` and `lib/models`.

```
lib/
├── core/
│   ├── constants/
│   │   └── mock_data.dart          # Centralized mock lists (roles, documents, inventory, staff)
│   └── network/
│       └── supabase_providers.dart # Singleton SupabaseClient exposed via Riverpod Provider
├── features/
│   ├── hr_dashboard/
│   │   ├── presentation/
│   │   │   ├── view_models/
│   │   │   │   └── hr_providers.dart          # HrNotifier: employee CRUD + Realtime subscription
│   │   │   └── views/
│   │   │       ├── hr_dashboard_screen.dart   # Form, multi/single-select sections, meeting scheduler
│   │   │       └── widgets/
│   │   │           └── employee_card.dart     # Live progress card via employeeTasksNotifierProvider
│   └── employee_view/
│       ├── presentation/
│       │   ├── view_models/
│       │   │   ├── employee_providers.dart    # EmployeeTasksNotifier + Realtime channel per employee
│       │   │   ├── employee_view_model.dart   # View mode toggle
│       │   │   └── chat_provider.dart         # RAG-enabled Gemini chat (ChatNotifier)
│       │   └── views/
│       │       ├── employee_screen.dart       # Split: My Schedule + My Action Items
│       │       └── widgets/
│       │           └── ai_chat_bottom_sheet.dart
├── models/
│   ├── employee.dart               # Employee: id, email, fullName, role
│   └── onboarding_task.dart        # OnboardingTask: id, employeeId, title, category,
│                                   #   isCompleted, scheduledAt?, assignedStaff?
├── providers/
│   └── view_mode_provider.dart     # Global HR ↔ Employee view toggle
└── main.dart                       # ProviderScope root, MaterialApp, theme
```

---

## Feature Modules

### HR Dashboard

The HR screen is a stateful `ConsumerStatefulWidget` that manages the full employee creation form as local ephemeral state, deliberately decoupled from Riverpod to avoid unnecessary global rebuilds.

**Employee creation flow:**
1. HR enters name and email via validated `TextFormField` widgets.
2. **Single-select role** — rendered as an animated `Wrap` of pill chips. Selecting any chip deselects the previous one. The "Add Employee" button is disabled until a role is chosen.
3. **Multi-select documents and inventory** — identical chip layout, independent toggle per item.
4. **Staff meeting scheduler** — opens a modal `Dialog` listing `mockStaff`, followed by Flutter's native `showDatePicker` and `showTimePicker`. Confirmed meetings are stored in `Map<String, DateTime> _scheduledMeetings` and displayed as removable inline rows.
5. On submit, `HrNotifier.addEmployee()` performs two sequential Supabase inserts: a bulk insert for document and equipment tasks (basic schema), then individual inserts per meeting task (with `scheduled_at`/`assigned_staff` and schema-safe fallback if those columns are absent).
6. Any insert failure surfaces immediately as a `SnackBar` — no silent drops.

**Employee grid:**
- Rendered as a responsive `GridView` with `mainAxisExtent: 190` (fixed height, no wasted space).
- Column count is dynamically computed from available width: `(width / 300).floor().clamp(1, 4)`.
- Each card watches `employeeTasksNotifierProvider(id)` — the live notifier — so progress bars update in real time without any manual refresh.

---

### Employee Screen

The employee screen is split into two semantically distinct sections inside a single `SingleChildScrollView`:

**My Schedule** — Meeting tasks only, sorted chronologically by `scheduledAt` (nulls last). Each row displays the meeting title, formatted date (`DD/MM/YYYY HH:MM`), assigned staff member, and a completion checkbox.

**My Action Items** — Document and Equipment tasks. Equipment tasks carry a visual health indicator: a colored left accent bar and a right square indicator that transitions from `#FF5252` (red, pending) to `#00E676` (green, completed) as the employee marks items done.

Both sections are populated from the same `AsyncNotifier` state — a single Supabase fetch filtered by `employee_id`, split at the presentation layer. No duplicate network calls.

---

## Data Model

### `Employee`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Auto-generated by Supabase |
| `email` | `text` | Unique |
| `full_name` | `text` | |
| `role` | `text` | Single value selected from `mockRoles` |

### `OnboardingTask`

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Auto-generated |
| `employee_id` | `uuid` | Foreign key → `employees.id` |
| `title` | `text` | Generated from selection: `'Review Document - NDA'`, `'Collect - Laptop'`, `'Meeting with Jordan (HR)'` |
| `category` | `text` | `'Document'` \| `'Equipment'` \| `'Meeting'` |
| `is_completed` | `bool` | Default `false` |
| `scheduled_at` | `timestamptz?` | Null for non-meeting tasks |
| `assigned_staff` | `text?` | Null for non-meeting tasks |

`OnboardingTask` implements safe null handling in `fromJson` — `scheduled_at` is parsed with `DateTime.tryParse` and silently treated as null if the column is absent or malformed.

---

## State Management

The project uses **Riverpod 3** throughout, with no `setState` used outside of local form state.

| Provider | Type | Scope |
|---|---|---|
| `supabaseClientProvider` | `Provider<SupabaseClient>` | Global singleton |
| `hrNotifierProvider` | `AsyncNotifierProvider<HrNotifier, List<Employee>>` | Global |
| `employeeTasksNotifierProvider` | `AsyncNotifierProvider.family<EmployeeTasksNotifier, List<OnboardingTask>, String>` | Per employee ID |
| `chatProvider` | `NotifierProvider.family<ChatNotifier, ChatState, String>` | Per employee ID |
| `selectedEmployeeIdProvider` | `NotifierProvider<..., String?>` | Global navigation |
| `isHrViewProvider` | `NotifierProvider<..., bool>` | Global view toggle |

The family providers are keyed by `employeeId`, ensuring each employee's tasks and chat history are isolated in separate provider instances and garbage-collected when no longer watched.

---

## Real-Time Synchronization

Both `HrNotifier` and `EmployeeTasksNotifier` open **Supabase Realtime channels** inside their `build()` methods, which run once on first watch and are torn down via `ref.onDispose()`.

```dart
// EmployeeTasksNotifier — scoped to a single employee
client
  .channel('tasks_$employeeId')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'onboarding_tasks',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'employee_id',
      value: employeeId,
    ),
    callback: (_) async => state = await AsyncValue.guard(_fetch),
  )
  .subscribe();
```

This means:
- **Device A (HR)** sees updated progress bars the moment **Device B (Employee)** checks off a task — no refresh button.
- **Device C (HR, another tab)** sees a newly created employee card appear automatically when Device A submits the form.
- All synchronization flows through Supabase's WebSocket layer backed by PostgreSQL `LISTEN/NOTIFY`.

> **Required:** Enable Realtime replication for `onboarding_tasks` and `employees` tables in the Supabase dashboard under **Database → Replication**.

---

## AI Assistant — RAG Pipeline

Each employee screen exposes a floating action button that opens `AiChatBottomSheet`. The chat is powered by a **Retrieval-Augmented Generation (RAG)** pipeline implemented in `ChatNotifier`:

1. **Retrieval** — On every message, the notifier queries Supabase for the employee's current task list (`employee_id = eq.{id}`), including title, category, and completion status.
2. **Context Construction** — The retrieved tasks are serialized into a structured plain-text context block injected as the Gemini system instruction.
3. **Generation** — `gemini-1.5-flash` generates a response grounded in the employee's actual data. It cannot hallucinate tasks that don't exist in the database.

```dart
final systemText =
  'You are the Navina Onboarding Assistant. '
  'The current employee has the following tasks:\n$taskLines\n'
  'Answer their questions briefly. '
  'If you don't know the answer, tell them exactly: '
  '"Please contact HR directly regarding this matter."';
```

The Gemini API key is injected at compile time via `--dart-define=GEMINI_API_KEY=<key>` and never hardcoded in source.

---

## Supabase Schema

```sql
create table employees (
  id        uuid primary key default gen_random_uuid(),
  email     text unique not null,
  full_name text not null,
  role      text not null
);

create table onboarding_tasks (
  id             uuid primary key default gen_random_uuid(),
  employee_id    uuid references employees(id) on delete cascade,
  title          text not null,
  category       text not null,
  is_completed   boolean not null default false,
  scheduled_at   timestamptz,
  assigned_staff text
);
```

---

## Environment Setup

### Prerequisites

- Flutter SDK ≥ 3.0
- A Supabase project with the schema above applied
- A Google AI Studio API key for Gemini

### Configuration

Create a `.env`-equivalent by passing `--dart-define` flags at run time:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_key_here \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

> The Supabase URL and anon key are read in `main.dart` via `String.fromEnvironment(...)`.

### Enable Realtime

In the Supabase dashboard:
1. Navigate to **Database → Replication**
2. Enable `supabase_realtime` publication for `employees` and `onboarding_tasks`

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome --dart-define=GEMINI_API_KEY=<key>

# Run as a headless web server (for AGI/CI testing)
flutter run -d web-server --web-port=8080 --dart-define=GEMINI_API_KEY=<key>

# Analyze for issues
flutter analyze
```

---

## Design System

The UI follows a **Corporate Blue** design language with modern 2026 rounding conventions.

| Token | Value | Usage |
|---|---|---|
| Primary | `#0A66C2` | Borders, headers, active states, icons |
| Background | `#FFFFFF` | All card and screen backgrounds |
| Surface | `#EEEEEE` | Unselected chips |
| Text | `#0D0D0D` | Primary body text |
| Muted | `#555555` | Secondary labels, dates |
| Equipment Pending | `#FF5252` | Red left bar — task not started |
| Equipment Done | `#00E676` | Green left bar — task completed |
| Error | `#8B0000` | Validation and error states |

**Border radius scale:**
- Cards / task rows: `16px`
- Dialogs: `20px`
- Buttons: `12px`
- Chips / role badges: `20px` (pill)
- Progress bars: `6px`
- Bottom sheet: `24px` top radius

Typography is set via Flutter's `ThemeData.textTheme` with the system default (Inter on web). All text styles are referenced from the theme — no inline font size literals outside the design system constants.
