# Phase 13: Employee Screen Splitting (Tasks & Meetings)

- [ ] Ensure you are inside the `navina_onboarding` directory.
- [ ] Open `lib/features/employee_view/presentation/views/employee_screen.dart`.
- [ ] In the `data` state of `employeeTasksNotifierProvider`, split the tasks list into two separate lists:
  - `final List<OnboardingTask> meetingTasks = tasks.where((t) => t.category == 'Meeting').toList();`
  - `final List<OnboardingTask> actionTasks = tasks.where((t) => t.category != 'Meeting').toList();`
- [ ] Sort `meetingTasks` chronologically by `scheduledAt`. Safely handle null dates by putting them at the end.
- [ ] Update the UI body to use a `SingleChildScrollView` containing a `Column` with two distinct sections:
  1. **My Schedule (Meetings)**:
     - Title: "My Schedule" (geometric styling, `headlineMedium` or similar).
     - Display the `meetingTasks`.
     - Render each meeting as a flat, bordered tile. Include the task title, `scheduledAt` (formatted readably: e.g., "DD/MM/YYYY HH:MM"), and `assignedStaff`. Include the completion checkbox.
  2. **My Action Items (Documents & Equipment)**:
     - Title: "My Action Items".
     - Display the `actionTasks` using the existing `_TaskRow` logic. Ensure the Red/Green Equipment logic (`t.category == 'Equipment'`) remains intact.
- [ ] Ensure flat, zero-elevation UI rules (`BorderRadius.zero`, strict Corporate Blue / White / Black palette) are strictly enforced across the new sections.
- [ ] Run `flutter analyze` to ensure zero errors.
- [ ] STRICT REQUIREMENT: Absolutely ZERO `//` or `/* */` comments allowed.
- [ ] LIVE FIELD TEST: Use the AGI Browser (`/browser`) to hit the local server. Click an employee card that has both tasks and meetings, and visually confirm the new two-section split layout renders correctly without overflow.