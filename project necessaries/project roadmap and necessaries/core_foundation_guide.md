# Core Foundation (Module 1) Implementation Guide

## 1. 🗺️ High-Level Roadmap
1. **Network Layer Setup**: Added `dio` for network requests and created a singleton `ApiClient`.
2. **Interceptors**: Created `AuthInterceptor` for JWT injection and token refresh, and `ErrorInterceptor` to handle global API errors.
3. **Core Models & Utils**: Implemented strongly-typed `AppException`s, generic `ApiResponse` wrappers, and global form `Validators`.
4. **State Management**: Added Riverpod providers for Dio (`dio_provider`) and Authentication state (`auth_provider`).
5. **Routing & Guards**: Migrated from standard Flutter Navigator to `go_router`, with dynamic `RouteGuards` driven by `AuthNotifier`.
6. **UI Integration**: Connected `LoginPage` and `RoleSelectionPage` to the new Riverpod `authProvider` and GoRouter navigation.

## 2. 🧠 Logical Descriptions

### 🧑‍💻 Simple Breakdown
- **Frontend**: We set up the "nervous system" of the app. It now knows how to talk to a server safely, how to handle "unauthorized" kick-outs, and how to protect sensitive pages (like a dashboard) from users who aren't logged in. 
- **Backend (Context)**: The backend API must return JWT tokens upon login, which the frontend will save securely and attach to every future request automatically.

### ⚙️ Technical Breakdown
- **Frontend Layer**: 
  - Uses `flutter_riverpod` for reactive, immutable state management (`AuthNotifier`).
  - Uses `dio` for HTTP networking, with interceptors that intercept requests *before* they leave the app to attach `Bearer <token>`.
  - Uses `go_router` which reacts to changes in `AuthNotifier`. If the user's token expires and the refresh fails, `AuthNotifier` sets `isAuthenticated = false`. `go_router` detects this and redirects to `/login`.

## 3. 💻 Full Implementation Code

### `lib/core/network/api_client.dart`
```dart
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(dio),
      ErrorInterceptor(),
      LogInterceptor(request: true, requestBody: true, responseBody: true, error: true),
    ]);
  }
}
```

### `lib/core/network/auth_interceptor.dart`
*(Core snippets shown for brevity in guide)*
```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null && !options.path.contains('/auth/')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### `lib/core/routing/route_guards.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../providers/auth_provider.dart';

class RouteGuards {
  static String? guardRoute(BuildContext context, GoRouterState state, AuthState authState) {
    final isLoggingIn = state.uri.path == '/login' || state.uri.path == '/' || state.uri.path == '/role';
    
    if (authState.isLoading) return null;
    if (!authState.isAuthenticated && !isLoggingIn) return '/';
    
    if (authState.isAuthenticated && isLoggingIn) {
      if (authState.role == AppConstants.rolePatient) return '/user';
      if (authState.role == AppConstants.roleDoctor) return '/doctor';
      if (authState.role == AppConstants.roleHospital) return '/authority';
    }
    return null;
  }
}
```

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const ProviderScope(child: NudhebApp()));
}

class NudhebApp extends ConsumerWidget {
  const NudhebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NUDHEB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
```

## 4. 🛠️ Extra Steps
1. **Dependencies**: `flutter pub add dio shared_preferences go_router flutter_riverpod`
2. **Environment Variables**: Configure API URL if deploying. Right now it defaults to `http://localhost:8080/api` via `AppConstants.baseUrl`.

## 5. 📝 Summary
1. The user logs in via `LoginPage`.
2. `AuthNotifier` sets state to authenticated and saves the mocked JWT to SharedPreferences.
3. `GoRouter` listens to `AuthNotifier` and re-evaluates `RouteGuards`.
4. `RouteGuards` sees the user is logged in and redirects them to their respective dashboard (e.g., `/user` or `/doctor`).
5. Future API requests made via `ApiClient` automatically have the `Bearer <token>` appended by `AuthInterceptor`.
