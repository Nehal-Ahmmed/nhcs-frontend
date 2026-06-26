import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class RouteGuards {
  static String? guardRoute(BuildContext context, GoRouterState state, AuthState authState) {
    final isAuthPage = state.uri.path == '/login' || 
                       state.uri.path == '/role' || 
                       state.uri.path.startsWith('/auth');
    
    final isPublicPage = state.uri.path == '/' || state.uri.path == '/search_doctors';

    if (authState.isLoading) {
      return null; // Wait for auth check to finish
    }

    if (!authState.isAuthenticated) {
      if (isAuthPage || isPublicPage) {
        return null; // Let them access public routes
      }
      return '/'; // Redirect to landing if not logged in and trying to access private route
    }

    // If logged in, redirect away from login/auth screens
    if (isAuthPage) {
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
    String getActiveDashboard(String? activeRole) {
      switch (activeRole) {
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

    if (state.uri.path.startsWith('/user') && authState.role != AppConstants.rolePatient) {
      return getActiveDashboard(authState.role);
    }
    if (state.uri.path.startsWith('/doctor') && authState.role != AppConstants.roleDoctor) {
      return getActiveDashboard(authState.role);
    }
    if (state.uri.path.startsWith('/authority') && authState.role != AppConstants.roleHospital) {
      return getActiveDashboard(authState.role);
    }
    if (state.uri.path.startsWith('/government') && authState.role != AppConstants.roleGovt) {
      return getActiveDashboard(authState.role);
    }

    return null; // Allowed
  }
}
