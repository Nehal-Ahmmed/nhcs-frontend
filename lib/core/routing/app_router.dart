import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'route_guards.dart';

import '../../features/auth/pages/landing_page.dart';
import '../../features/auth/pages/role_selection_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/patient/pages/patient_shell.dart';
import '../../features/doctor/pages/doctor_shell.dart';
import '../../features/hospital/pages/hospital_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (context, state) => RouteGuards.guardRoute(context, state, authState),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/role',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          // Passing role logic if needed, but LoginPage usually handles it
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const PatientShell(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorShell(),
      ),
      GoRoute(
        path: '/authority',
        builder: (context, state) => const HospitalShell(),
      ),
    ],
  );
});

// Helper to convert StateNotifier stream to Listenable for GoRouter
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
