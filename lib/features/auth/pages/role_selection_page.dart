import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(Icons.health_and_safety_rounded, size: 56, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                'NUDHEB',
                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                'National Unified Digital Healthcare Ecosystem',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted, letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Role cards
              SizedBox(
                width: 500,
                child: Column(
                  children: [
                    _buildRoleCard(
                      context,
                      icon: Icons.person_rounded,
                      title: 'Citizen / Patient',
                      subtitle: 'Access your health records, book appointments, and manage your healthcare journey',
                      gradient: [AppColors.primary, const Color(0xFF1976D2)],
                      onTap: () => context.push('/login?role=patient'),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      icon: Icons.medical_services_rounded,
                      title: 'Doctor',
                      subtitle: 'Manage patients, create treatments, and access clinical tools',
                      gradient: [AppColors.secondary, const Color(0xFF0EA5E9)],
                      onTap: () => context.push('/login?role=doctor'),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      icon: Icons.local_hospital_rounded,
                      title: 'Hospital Authority',
                      subtitle: 'Manage hospital operations, staff, laboratories, and resources',
                      gradient: [const Color(0xFF7C3AED), const Color(0xFF6366F1)],
                      onTap: () => context.push('/login?role=authority'),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      icon: Icons.account_balance_rounded,
                      title: 'Government Authority',
                      subtitle: 'National health intelligence, disease surveillance, and policy support',
                      gradient: [const Color(0xFFDC2626), const Color(0xFFF97316)],
                      onTap: () => context.push('/login?role=govt'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '© 2026 Ministry of Health and Family Welfare, Bangladesh',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
