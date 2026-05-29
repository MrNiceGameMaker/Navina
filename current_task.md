# Phase 14: Generate Project Documentation (README.md)

- [ ] Ensure you are inside the `navina_onboarding` directory.
- [ ] Create a highly professional `README.md` file in English at the root of the project.
- [ ] The README must comprehensively document the following aspects:
  - **Title & Overview**: "Navina Onboarding Platform" - A high-performance, real-time employee onboarding orchestration engine.
  - **Core Architecture**: Flutter Web, Supabase (live database + Realtime Postgres subscriptions), and Riverpod 3.x (AsyncNotifier/Notifier) for reactive state management.
  - **Design System (Execution Engine Paradigm)**: Rejection of generic social media UI in favor of a zero-elevation, geometric interface (BorderRadius.zero), Corporate Blue (`#0A66C2`) and white palette, designed for high-density enterprise workflows.
  - **Key Features**: 
    - HR Dashboard: Dynamic task generation, multi-choice entity selection, staff scheduling with automatic robust database fallbacks.
    - Employee View: Split layout ('My Schedule' for chronological meetings and 'My Action Items' with Red/Green dynamic hardware tracking indicators).
  - **AI Integration**: Live Google Gemini (`gemini-1.5-flash`) integration acting as a context-aware Assistant, using real-time RAG (Retrieval-Augmented Generation) by injecting the employee's Supabase tasks directly into the system prompt.
  - **Code Quality**: Strict zero-comments rule (`//` or `/* */`), and 100% clean `flutter analyze` compilation.
  - **Getting Started**: Provide the terminal command to run the application with the injected API key: `flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_ACTUAL_API_KEY`.
- [ ] Write the file and reply confirming the README is generated.