import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

// Sidebar for patient role
class PatientSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const PatientSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('NUDHEB', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const WorkspaceSwitcher(),
          const SizedBox(height: 24),
          // Menu items
          _buildMenuItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildMenuItem(1, Icons.timeline_rounded, 'Health Timeline'),
          _buildMenuItem(2, Icons.calendar_month_rounded, 'Appointments'),
          _buildMenuItem(3, Icons.folder_shared_rounded, 'Medical Vault'),
          _buildMenuItem(4, Icons.person_rounded, 'My Profile'),
          _buildMenuItem(5, Icons.auto_awesome_rounded, 'AI Assistant'),
          const Spacer(),
          // Go to Website
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text('Go to Website', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => ref.read(authProvider.notifier).logout(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

// Sidebar for doctor role
class DoctorSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DoctorSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('NUDHEB', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Doctor Portal', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          const WorkspaceSwitcher(),
          const SizedBox(height: 24),
          _buildMenuItem(0, Icons.dashboard_rounded, 'Dashboard'),
          _buildMenuItem(1, Icons.edit_note_rounded, 'Clinical Workspace'),
          _buildMenuItem(2, Icons.science_rounded, 'Report Review'),
          _buildMenuItem(3, Icons.schedule_rounded, 'My Schedule'),
          _buildMenuItem(4, Icons.person_rounded, 'Profile'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text('Go to Website', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => ref.read(authProvider.notifier).logout(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.primary : Colors.transparent),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar for hospital authority role
class HospitalSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const HospitalSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('NUDHEB', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Hospital Authority', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          const WorkspaceSwitcher(),
          const SizedBox(height: 24),
          _buildMenuItem(0, Icons.dashboard_rounded, 'Command Center'),
          _buildMenuItem(1, Icons.receipt_long_rounded, 'Reception & Queue'),
          _buildMenuItem(2, Icons.people_rounded, 'Staff Management'),
          _buildMenuItem(3, Icons.biotech_rounded, 'Laboratory'),
          _buildMenuItem(4, Icons.bed_rounded, 'Bed Management'),
          _buildMenuItem(5, Icons.medication_rounded, 'Pharmacy'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text('Go to Website', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => ref.read(authProvider.notifier).logout(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.primary : Colors.transparent),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sidebar for government authority role
class GovtSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const GovtSidebar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('NUDHEB', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Government Authority', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          const WorkspaceSwitcher(),
          const SizedBox(height: 24),
          _buildMenuItem(0, Icons.dashboard_rounded, 'National Overview'),
          _buildMenuItem(1, Icons.folder_shared_rounded, 'National Registries'),
          _buildMenuItem(2, Icons.biotech_rounded, 'Disease Intelligence'),
          _buildMenuItem(3, Icons.map_rounded, 'Resource Map'),
          _buildMenuItem(4, Icons.gavel_rounded, 'Compliance Center'),
          _buildMenuItem(5, Icons.assignment_rounded, 'Role Applications'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text('Go to Website', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => ref.read(authProvider.notifier).logout(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withOpacity(0.05)),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? AppColors.primary : Colors.transparent),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textMuted, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkspaceSwitcher extends ConsumerWidget {
  const WorkspaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final roles = authState.roles;
    final currentRole = authState.role;

    if (roles.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          dropdownColor: AppColors.sidebar,
          icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
          isExpanded: true,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          items: roles.map((role) {
            String displayName = 'Citizen Workspace';
            IconData icon = Icons.person_rounded;
            Color iconColor = AppColors.primary;

            if (role == AppConstants.roleDoctor) {
              displayName = 'Doctor Console';
              icon = Icons.medical_services_rounded;
              iconColor = AppColors.secondary;
            } else if (role == AppConstants.roleHospital) {
              displayName = 'Hospital Center';
              icon = Icons.local_hospital_rounded;
              iconColor = const Color(0xFF7C3AED);
            } else if (role == AppConstants.roleGovt) {
              displayName = 'Govt Command';
              icon = Icons.account_balance_rounded;
              iconColor = const Color(0xFFDC2626);
            }

            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Text(displayName, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
          onChanged: (newRole) {
            if (newRole != null && newRole != currentRole) {
              ref.read(authProvider.notifier).switchRole(newRole);
            }
          },
        ),
      ),
    );
  }
}
