# NUDHEB Frontend Architecture Guide

## 🗺️ High-Level Roadmap
1. Removed old `lib/screens` directory.
2. Initialized Clean Architecture / Feature-First structure.
3. Set up core routing (`go_router`), state management (`flutter_riverpod`), and design system (`google_fonts`, custom `app_theme.dart`).
4. Created base authentication UI for role selection.
5. Implemented foundational dashboards for Patient, Doctor, and Hospital Authority ecosystems.

## 🧠 Logical Descriptions

### Frontend Layer
- **Core Package**: `lib/core` handles application-wide configurations such as `AppRouter`, `AppTheme`, and `AppConstants`.
- **Features Package**: `lib/features` is modularly split by ecosystem:
  - `auth`: Handles role selection (`/`) and login (`/login`).
  - `patient`: Contains citizen views (`/user`), displaying personal health records and appointments.
  - `doctor`: Contains clinical workspaces (`/doctor`), displaying daily queues and patient data.
  - `hospital`: Contains administrative commands (`/authority`), monitoring active patients, beds, and resources.
- **Routing**: `go_router` handles deep linking, allowing the system to direct users to specific sub-systems cleanly based on their auth role.
- **Theming**: A unified premium theme combining Deep Ocean Blue and white surfaces ensures consistency and a professional look.

## 💻 Full Implementation Code

*Note: Since the codebase involves multiple files, we highlight the entry point and routing below. The rest of the implementation exists inside `lib/features/` and `lib/core/`.*

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NUDHEB Ecosystem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
```

## 🛠️ Extra Steps
- To run the project locally, execute `flutter run` in the root directory.
- `flutter_riverpod` is added for state management; as the app scales, each feature will implement `domain` and `data` layers communicating via providers.
- Future database connectivity will be integrated into the respective feature's `data` layer.

## 📝 Summary
The frontend is now cleanly segregated by the primary user ecosystems (Citizen, Doctor, Hospital Authority). Role selection routes the user to their respective dashboard, which employs a unified, premium UI framework. This architecture easily supports the addition of new features like telemedicine and AI assistants without cluttering the global scope.
