import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dio_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String role;
  const LoginPage({super.key, this.role = 'patient'});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-fill dummy credentials for easy testing
    switch (widget.role) {
      case 'doctor':
        _usernameController.text = 'doctor';
        _passwordController.text = 'password123';
        break;
      case 'authority':
        _usernameController.text = 'hospital';
        _passwordController.text = 'password123';
        break;
      case 'govt':
        _usernameController.text = 'govt';
        _passwordController.text = 'password123';
        break;
      case 'patient':
      default:
        _usernameController.text = 'patient';
        _passwordController.text = 'password123';
        break;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
      });

      final token = response.data['token'];
      final role = response.data['role'];

      // Update Auth State, which triggers GoRouter redirect automatically
      await ref.read(authProvider.notifier).login(token, '', role);
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid username or password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Citizen Login';
    IconData icon = Icons.person_rounded;
    List<Color> gradient = [AppColors.primary, const Color(0xFF1976D2)];

    if (widget.role == 'doctor') {
      title = 'Doctor Login';
      icon = Icons.medical_services_rounded;
      gradient = [AppColors.secondary, const Color(0xFF0EA5E9)];
    } else if (widget.role == 'authority') {
      title = 'Hospital Authority Login';
      icon = Icons.local_hospital_rounded;
      gradient = [const Color(0xFF7C3AED), const Color(0xFF6366F1)];
    } else if (widget.role == 'govt') {
      title = 'Government Authority Login';
      icon = Icons.account_balance_rounded;
      gradient = [const Color(0xFFDC2626), const Color(0xFFF97316)];
    }

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
                    // Uses router to pop
                    onTap: () => context.pop(),
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
                const SizedBox(height: 24),
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to continue',
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 14)),
                ],
                const SizedBox(height: 36),
                // Email field
                TextField(
                  controller: _usernameController,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Health ID / Email',
                    labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.textMuted, size: 20),
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
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                    suffixIcon: const Icon(Icons.visibility_off_outlined, color: AppColors.textMuted, size: 20),
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?', style: GoogleFonts.inter(color: gradient[0], fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 20),
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text('Sign In', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: Text('Register', style: GoogleFonts.inter(color: gradient[0], fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
