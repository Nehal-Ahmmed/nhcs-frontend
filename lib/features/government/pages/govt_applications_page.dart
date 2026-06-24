import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/application_provider.dart';

class GovtApplicationsPage extends ConsumerWidget {
  const GovtApplicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsState = ref.watch(pendingApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role Applications Review',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approve or reject incoming requests for Doctor, Hospital Admin, or Super Admin roles.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(pendingApplicationsProvider.notifier).fetchPendingApplications(),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  tooltip: 'Refresh Applications',
                ),
              ],
            ),
          ),
          Expanded(
            child: applicationsState.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text('No pending applications', style: GoogleFonts.outfit(fontSize: 18, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(32),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return _buildApplicationCard(context, ref, app);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, st) => Center(child: Text('Error loading applications: $err', style: const TextStyle(color: AppColors.danger))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, WidgetRef ref, RoleApplication app) {
    Color roleColor = AppColors.primary;
    IconData roleIcon = Icons.person_rounded;
    if (app.requestedRole == 'DOCTOR') {
      roleColor = AppColors.secondary;
      roleIcon = Icons.medical_services_rounded;
    } else if (app.requestedRole == 'HOSPITAL') {
      roleColor = Colors.purpleAccent;
      roleIcon = Icons.local_hospital_rounded;
    } else if (app.requestedRole == 'GOVT') {
      roleColor = AppColors.danger;
      roleIcon = Icons.account_balance_rounded;
    }

    final date = DateTime.tryParse(app.applicationDate);
    String formattedDate = app.applicationDate;
    if (date != null) {
      formattedDate = '${_monthName(date.month)} ${date.day}, ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(roleIcon, color: roleColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Request for ${app.requestedRole} Role',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        app.status,
                        style: GoogleFonts.inter(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Submitted on: $formattedDate', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 12),
                if (app.notes != null && app.notes!.isNotEmpty) ...[
                  Text('Applicant Notes:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(app.notes!, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(pendingApplicationsProvider.notifier).approveApplication(app.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Approved!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to approve: $e')));
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(pendingApplicationsProvider.notifier).rejectApplication(app.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Rejected')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject: $e')));
                  }
                },
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
