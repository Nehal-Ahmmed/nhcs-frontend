import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class RouteGuards {
  static String? guardRoute(BuildContext context, GoRouterState state, AuthState authState) {
    final isLoggingIn = state.uri.path == '/login' || 
                        state.uri.path == '/role' || 
                        state.uri.path == '/' ||
                        state.uri.path.startsWith('/auth');

    if (authState.isLoading) {
      return null; // Wait for auth check to finish
    }

    if (!authState.isAuthenticated) {
      if (isLoggingIn) {
        return null; // Let them access public routes
      }
      return '/'; // Redirect to landing if not logged in and trying to access private route
    }

    // If logged in, redirect away from login screens
    if (isLoggingIn) {
      switch (authState.role) {
        case AppConstants.rolePatient:
          return '/user';
        case AppConstants.roleDoctor:
          return '/doctor';
        case AppConstants.roleHospital:
          return '/authority';
        case AppConstants.roleGovt:
          return '/government';
        default:
          return '/';
      }
    }

    // Role-based protection for private routes
    if (state.uri.path.startsWith('/user') && authState.role != AppConstants.rolePatient) {
      return '/login'; // Or their specific dashboard
    }
    if (state.uri.path.startsWith('/doctor') && authState.role != AppConstants.roleDoctor) {
      return '/login';
    }
    if (state.uri.path.startsWith('/authority') && authState.role != AppConstants.roleHospital) {
      return '/login';
    }
    if (state.uri.path.startsWith('/government') && authState.role != AppConstants.roleGovt) {
      return '/login';
    }

    return null; // Allowed
  }
}
