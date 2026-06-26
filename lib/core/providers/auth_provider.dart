import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

// Import feature-level providers to invalidate them on logout
import '../../features/patient/presentation/providers/patient_providers.dart';
import '../../features/patient/presentation/providers/booking_provider.dart';
import '../../features/doctor/presentation/providers/doctor_providers.dart';
import '../../features/doctor/presentation/providers/clinical_workspace_provider.dart';
import '../../features/hospital/presentation/providers/hospital_providers.dart';
import '../../features/government/presentation/providers/govt_providers.dart';
import 'notifications_provider.dart';

class AuthState {
  final bool isAuthenticated;
  final String? role; // Active role
  final List<String> roles; // All approved roles
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.role,
    this.roles = const [],
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? role,
    List<String>? roles,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final role = prefs.getString(AppConstants.userRoleKey);
    final roles = prefs.getStringList('user_roles') ?? [];

    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        isAuthenticated: true,
        role: role,
        roles: roles.isEmpty && role != null ? [role] : roles,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        roles: const [],
        isLoading: false,
      );
    }
  }

  Future<void> login(String token, String refreshToken, String activeRole, List<String> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    await prefs.setString(AppConstants.userRoleKey, activeRole);
    await prefs.setStringList('user_roles', roles);

    state = state.copyWith(
      isAuthenticated: true,
      role: activeRole,
      roles: roles,
      isLoading: false,
    );

    // Force invalidation of all user data providers to trigger fresh queries with the new token
    _invalidateAllUserCache();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove('user_roles');

    state = state.copyWith(
      isAuthenticated: false,
      role: null,
      roles: const [],
      isLoading: false,
    );

    // Force invalidation of all user data providers to clear cache in memory
    _invalidateAllUserCache();
  }

  void _invalidateAllUserCache() {
    // Invalidate patient providers
    ref.invalidate(patientDashboardSummaryProvider);
    ref.invalidate(patientAiHealthSummaryProvider);
    ref.invalidate(patientProfileProvider);
    ref.invalidate(patientTimelineProvider);
    ref.invalidate(patientAppointmentsProvider);
    ref.invalidate(patientPrescriptionsProvider);
    ref.invalidate(patientLabReportsProvider);
    ref.invalidate(patientImagingReportsProvider);
    ref.invalidate(patientNavigationProvider);
    ref.invalidate(bookingProvider);

    // Invalidate doctor providers
    ref.invalidate(doctorNavigationProvider);
    ref.invalidate(doctorDashboardProvider);
    ref.invalidate(patientQueueProvider);
    ref.invalidate(pendingReportsProvider);
    ref.invalidate(clinicalWorkspaceProvider);

    // Invalidate hospital providers
    ref.invalidate(hospitalNavigationProvider);
    ref.invalidate(hospitalDashboardStatsProvider);
    ref.invalidate(receptionQueueProvider);
    ref.invalidate(staffRosterProvider);
    ref.invalidate(doctorVerificationsProvider);
    ref.invalidate(laboratoryQueueProvider);
    ref.invalidate(bedCapacityProvider);
    ref.invalidate(pharmacyInventoryProvider);

    // Invalidate government providers
    ref.invalidate(govtNavigationProvider);
    ref.invalidate(govtDashboardStatsProvider);
    ref.invalidate(govtCitizenRegistryProvider);
    ref.invalidate(govtDoctorRegistryProvider);
    ref.invalidate(govtHospitalRegistryProvider);
    ref.invalidate(govtResourcesProvider);
    ref.invalidate(govtAuditLogsProvider);

    // Invalidate notification providers
    ref.invalidate(patientNotificationsProvider);
    ref.invalidate(doctorNotificationsProvider);
    ref.invalidate(hospitalNotificationsProvider);
    ref.invalidate(govtNotificationsProvider);
  }

  Future<void> switchRole(String newRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userRoleKey, newRole);
    state = state.copyWith(role: newRole);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
