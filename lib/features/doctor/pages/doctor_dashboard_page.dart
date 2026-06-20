import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../presentation/providers/doctor_providers.dart';
import '../presentation/providers/clinical_workspace_provider.dart';
import '../data/models/patient_queue_item.dart';

class DoctorDashboardPage extends ConsumerWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(doctorDashboardProvider);
    final queueAsync = ref.watch(patientQueueProvider);
    final notifications = ref.watch(doctorNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning, Dr. Ahmed', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('Cardiology Department • Dhaka Central Hospital', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                NotificationDropdown(
                  notifications: notifications,
                  onMarkRead: (id) => ref.read(doctorNotificationsProvider.notifier).markAsRead(id),
                  onMarkAllRead: () => ref.read(doctorNotificationsProvider.notifier).markAllAsRead(),
                  onNavigate: (tabIndex) {
                    ref.read(doctorNavigationProvider.notifier).state = tabIndex;
                  },
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard summary & AI briefing
                  dashboardAsync.when(
                    data: (summary) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            _statCard('Today\'s Patients', summary.totalAppointments.toString(), Icons.people_rounded, AppColors.primary, '+2 vs yesterday'),
                            const SizedBox(width: 16),
                            _statCard('Follow-ups', summary.totalFollowUps.toString(), Icons.replay_rounded, AppColors.secondary, '2 scheduled'),
                            const SizedBox(width: 16),
                            _statCard('Emergency', summary.emergencyCases.toString(), Icons.emergency_rounded, AppColors.danger, 'Action required'),
                            const SizedBox(width: 16),
                            _statCard('Pending Reports', summary.pendingReports.toString(), Icons.science_rounded, AppColors.warning, '3 unread'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AiInsightPanel(
                          title: 'AI Daily Briefing & Patient Summary',
                          description: summary.aiBriefing,
                          type: 'success',
                          recommendations: const [
                            'Check-in on Emergency consult Patient: Fatema Zohra immediately.',
                            'Verify pending CBC lab report for Rahim Islam.',
                            'Prepare weekly clinical shift roster update for approval.'
                          ],
                        ),
                      ],
                    ),
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, _) => Text('Error loading summary: $err'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Patient Queue Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Patient Queue — Today', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                      queueAsync.when(
                        data: (queue) {
                          final waitingCount = queue.where((p) => p.visitType != 'Emergency').length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('$waitingCount waiting • 1 active', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Patient Queue List
                  queueAsync.when(
                    data: (queue) => ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: queue.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        return _queueCard(context, ref, item);
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading queue: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, {String? badge}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
              child: Text(badge, style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _queueCard(BuildContext context, WidgetRef ref, PatientQueueItem item) {
    final bool isActive = item.visitType == 'Follow-up' && item.name == 'Rahim Islam'; // Highlight first patient
    final Color statusColor = isActive ? AppColors.info : AppColors.warning;
    final String statusText = isActive ? 'IN CONSULTATION' : 'WAITING';

    Color riskColor = item.riskIndicator == 'Emergency' 
        ? AppColors.danger 
        : item.riskIndicator == 'High' 
            ? Colors.orange 
            : item.riskIndicator == 'Moderate' 
                ? AppColors.warning 
                : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.5) : AppColors.divider.withOpacity(0.5)),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))] : null,
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 80,
            child: Text(item.time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.name[0],
                style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(width: 8),
                    Text('${item.age} ${item.gender[0]}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.existingDiseases.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
                    child: Text(c, style: GoogleFonts.inter(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
              ],
            ),
          ),
          // Visit type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
            child: Text(item.visitType, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          // Risk
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(item.riskIndicator, style: GoogleFonts.inter(color: riskColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusText, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          // Action Button
          ElevatedButton(
            onPressed: () {
              // Initialize Workspace Provider with this patient's details
              ref.read(clinicalWorkspaceProvider.notifier).initializePatient(item.healthId, item.name);
              // Switch tab to Clinical Workspace (Index 1)
              ref.read(doctorNavigationProvider.notifier).state = 1;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.primary : Colors.grey.shade200,
              foregroundColor: isActive ? Colors.white : AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isActive ? 'Continue' : 'Start', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
