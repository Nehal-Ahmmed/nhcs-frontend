import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

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
  AuthNotifier() : super(AuthState()) {
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
  }

  Future<void> switchRole(String newRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userRoleKey, newRole);
    state = state.copyWith(role: newRole);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
