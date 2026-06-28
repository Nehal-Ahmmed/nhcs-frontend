import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/network/api_endpoints.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? role;
  const LoginPage({super.key, this.role});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  static const List<Map<String, String>> _demoUsers = [
    // Super Admin (1)
    {'username': 'nehal', 'role': 'Super Admin', 'icon': '👑', 'pass': '123456'},
    // Patients (5)
    {'username': 'patient_100', 'role': 'Patient', 'icon': '👤', 'pass': 'password123'},
    {'username': 'patient_101', 'role': 'Patient', 'icon': '👤', 'pass': 'password123'},
    {'username': 'patient_102', 'role': 'Patient', 'icon': '👤', 'pass': 'password123'},
    {'username': 'patient_103', 'role': 'Patient', 'icon': '👤', 'pass': 'password123'},
    {'username': 'patient_104', 'role': 'Patient', 'icon': '👤', 'pass': 'password123'},
    // Doctors (5)
    {'username': 'doctor_100', 'role': 'Doctor', 'icon': '🩺', 'pass': 'password123'},
    {'username': 'doctor_101', 'role': 'Doctor', 'icon': '🩺', 'pass': 'password123'},
    {'username': 'doctor_102', 'role': 'Doctor', 'icon': '🩺', 'pass': 'password123'},
    {'username': 'doctor_103', 'role': 'Doctor', 'icon': '🩺', 'pass': 'password123'},
    {'username': 'doctor_104', 'role': 'Doctor', 'icon': '🩺', 'pass': 'password123'},
    // Hospitals (5)
    {'username': 'hospital_100', 'role': 'Hospital', 'icon': '🏥', 'pass': 'password123'},
    {'username': 'hospital_101', 'role': 'Hospital', 'icon': '🏥', 'pass': 'password123'},
    {'username': 'hospital_102', 'role': 'Hospital', 'icon': '🏥', 'pass': 'password123'},
    {'username': 'hospital_103', 'role': 'Hospital', 'icon': '🏥', 'pass': 'password123'},
    {'username': 'hospital_104', 'role': 'Hospital', 'icon': '🏥', 'pass': 'password123'},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill dummy credentials for easy testing
    switch (widget.role) {
      case 'doctor':
        _usernameController.text = 'doctor_100';
        _passwordController.text = 'password123';
        break;
      case 'authority':
        _usernameController.text = 'hospital_100';
        _passwordController.text = 'password123';
        break;
      case 'govt':
        _usernameController.text = 'nehal';
        _passwordController.text = 'password123';
        break;
      case 'patient':
      default:
        _usernameController.text = 'patient_100';
        _passwordController.text = 'password123';
        break;
    }
  }

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _fullNameController.text.trim();

    if (username.isEmpty || password.isEmpty || (_isSignUp && (email.isEmpty || fullName.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Real API Authentication
      final dio = ref.read(dioProvider);

      if (_isSignUp) {
        // Register request
        final response = await dio.post(
          ApiEndpoints.register,
          data: {
            'username': username,
            'email': email,
            'password': password,
            'fullName': fullName,
            'role': 'PATIENT',
          },
        );

        final data = response.data;
        final token = data['token'] as String;
        final dynamicRoles = List<String>.from(data['roles'] as List);

        await ref.read(authProvider.notifier).login(
          token,
          'refresh_token_not_provided',
          'PATIENT',
          dynamicRoles,
        );
      } else {
        // Login request
        final response = await dio.post(
          ApiEndpoints.login,
          data: {
            'username': username,
            'password': password,
          },
        );

        final data = response.data;
        final token = data['token'] as String;
        final dynamicRoles = List<String>.from(data['roles'] as List);
        
        // Select default active role (e.g. PATIENT)
        String defaultRole = 'PATIENT';
        if (dynamicRoles.contains('GOVT')) {
          defaultRole = 'GOVT';
        } else if (dynamicRoles.contains('HOSPITAL')) {
          defaultRole = 'HOSPITAL';
        } else if (dynamicRoles.contains('DOCTOR')) {
          defaultRole = 'DOCTOR';
        }

        await ref.read(authProvider.notifier).login(
          token,
          'refresh_token_not_provided',
          defaultRole,
          dynamicRoles,
        );
      }

      if (mounted) {
        final activeRole = ref.read(authProvider).role;
        String targetRoute = '/role';
        if (activeRole == 'PATIENT') {
          targetRoute = '/user';
        } else if (activeRole == 'DOCTOR') {
          targetRoute = '/doctor';
        } else if (activeRole == 'HOSPITAL') {
          targetRoute = '/authority';
        } else if (activeRole == 'GOVT') {
          targetRoute = '/government';
        }
        context.go(targetRoute);
      }
    } catch (e) {
      String errMsg = 'Authentication failed';
      if (e is DioException) {
        errMsg = e.response?.data?['message'] ?? e.message ?? errMsg;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = [AppColors.primary, AppColors.secondary];

    return Scaffold(
      backgroundColor: AppColors.sidebar,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => context.go('/'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  'NUDHEB Portal',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Create your national health account' : 'Enter your credentials to continue',
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Sliding Switcher Tab
                Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isSignUp = false),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_isSignUp ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isSignUp = true),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isSignUp ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Username field
                TextField(
                  controller: _usernameController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                    suffixIcon: _isSignUp
                        ? null
                        : PopupMenuButton<Map<String, String>>(
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: AppColors.textMuted,
                              size: 28,
                            ),
                            tooltip: 'Quick Login Select',
                            color: AppColors.sidebarHover,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                              maxWidth: 320,
                            ),
                            offset: const Offset(0, 48),
                            onSelected: (user) {
                              _usernameController.text = user['username']!;
                              _passwordController.text = user['pass']!;
                            },
                            itemBuilder: (context) {
                              return _demoUsers.map((user) {
                                final isSuperAdmin = user['username'] == 'nehal';
                                return PopupMenuItem<Map<String, String>>(
                                  value: user,
                                  child: Row(
                                    children: [
                                      Text(user['icon']!, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          user['username']!,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: isSuperAdmin ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSuperAdmin
                                              ? Colors.amber.withOpacity(0.2)
                                              : user['role'] == 'Doctor'
                                                  ? Colors.cyan.withOpacity(0.2)
                                                  : user['role'] == 'Hospital'
                                                      ? Colors.purple.withOpacity(0.2)
                                                      : Colors.blue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSuperAdmin
                                                ? Colors.amber.withOpacity(0.4)
                                                : user['role'] == 'Doctor'
                                                    ? Colors.cyan.withOpacity(0.4)
                                                    : user['role'] == 'Hospital'
                                                        ? Colors.purple.withOpacity(0.4)
                                                        : Colors.blue.withOpacity(0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          isSuperAdmin ? 'SUPER ADMIN 👑' : user['role']!.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            color: isSuperAdmin
                                                ? Colors.amber
                                                : user['role'] == 'Doctor'
                                                    ? Colors.cyanAccent
                                                    : user['role'] == 'Hospital'
                                                        ? Colors.purpleAccent
                                                        : Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: gradient[0]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isSignUp) ...[
                  // Full Name field
                  TextField(
                    controller: _fullNameController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textMuted, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: gradient[0]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  TextField(
                    controller: _emailController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textMuted, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: gradient[0]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: gradient[0]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isSignUp ? 'Create Account' : 'Sign In',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
