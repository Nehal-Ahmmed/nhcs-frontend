import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../data/models/appointment.dart';
import '../data/models/dashboard_summary.dart';
import '../data/models/medical_record.dart';
import '../data/models/patient_profile.dart';
import '../presentation/providers/patient_providers.dart';

class PatientDashboardPage extends ConsumerWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(patientProfileProvider);
    final aiSummaryState = ref.watch(patientAiHealthSummaryProvider);
    final appointmentsState = ref.watch(patientAppointmentsProvider);
    final prescriptionsState = ref.watch(patientPrescriptionsProvider);
    final labReportsState = ref.watch(patientLabReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $err', style: GoogleFonts.inter(color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(patientProfileProvider);
                  ref.invalidate(patientDashboardSummaryProvider);
                  ref.invalidate(patientAiHealthSummaryProvider);
                  ref.invalidate(patientAppointmentsProvider);
                  ref.invalidate(patientPrescriptionsProvider);
                  ref.invalidate(patientLabReportsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          return Row(
            children: [
              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context, ref),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHealthCard(profile),
                            const SizedBox(height: 24),
                            aiSummaryState.when(
                              loading: () => const LinearProgressIndicator(color: AppColors.warning),
                              error: (e, s) => const SizedBox.shrink(),
                              data: (aiSummary) => _buildAISummary(aiSummary),
                            ),
                            const SizedBox(height: 24),
                            Text('Quick Services', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildSectionRow(prescriptionsState, appointmentsState),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right panel
              _buildRightPanel(profile, labReportsState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(patientNotificationsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search records, doctors, appointments...',
                        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          NotificationDropdown(
            notifications: notifications,
            onMarkRead: (id) => ref.read(patientNotificationsProvider.notifier).markAsRead(id),
            onMarkAllRead: () => ref.read(patientNotificationsProvider.notifier).markAllAsRead(),
            onNavigate: (tabIndex) {
              ref.read(patientNavigationProvider.notifier).state = tabIndex;
            },
          ),
          const SizedBox(width: 8),
          _headerIcon(Icons.settings_outlined),
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

  Widget _buildHealthCard(PatientProfile profile) {
    final age = DateTime.now().year - profile.dateOfBirth.year;
    final allergiesStr = profile.allergies.isEmpty 
        ? 'None' 
        : profile.allergies.map((e) => e.allergen).join(', ');
    final chronicStr = profile.chronicDiseases.isEmpty 
        ? 'None' 
        : profile.chronicDiseases.map((e) => e.diseaseName).join(', ');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0A4B75), Color(0xFF083B5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NUDHEB Digital Health Card', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(profile.healthId, style: GoogleFonts.inter(color: Colors.white60, fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cardStat('Blood Group', profile.bloodGroup),
                _cardStatDivider(),
                _cardStat('Age', age.toString()),
                _cardStatDivider(),
                _cardStat('Allergies', allergiesStr),
                _cardStatDivider(),
                _cardStat('Chronic', chronicStr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _cardStatDivider() {
    return Container(width: 1, height: 30, color: Colors.white.withOpacity(0.15));
  }

  Widget _buildAISummary(AiHealthSummary summary) {
    return AiInsightPanel(
      title: 'AI Health Assessment & Vitals Briefing',
      description: summary.summaryText,
      type: 'warning',
      recommendations: const [
        'Vitals are stable, keep monitoring BP daily.',
        'Take prescribed Metformin 500mg as instructed by Dr. Ahmed Khan.',
        'Avoid high sodium meals and keep well hydrated.'
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionCard(Icons.calendar_month_rounded, 'Book Appointment', AppColors.primary),
        const SizedBox(width: 16),
        _actionCard(Icons.timeline_rounded, 'Health Timeline', AppColors.secondary),
        const SizedBox(width: 16),
        _actionCard(Icons.folder_shared_rounded, 'Medical Vault', const Color(0xFFF59E0B)),
        const SizedBox(width: 16),
        _actionCard(Icons.auto_awesome_rounded, 'AI Assistant', const Color(0xFF6366F1)),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionRow(
    AsyncValue<List<Prescription>> prescriptionsState,
    AsyncValue<List<Appointment>> appointmentsState,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Prescriptions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Active Prescriptions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              prescriptionsState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.teal)),
                error: (err, stack) => Text('Error loading prescriptions: $err'),
                data: (prescriptions) {
                  if (prescriptions.isEmpty) {
                    return Text('No active prescriptions', style: GoogleFonts.inter(color: AppColors.textMuted));
                  }
                  // Let's show up to 3 medications from prescriptions
                  final activeMeds = prescriptions.expand((p) => p.medicines).take(3).toList();
                  if (activeMeds.isEmpty) {
                    return Text('No active medications', style: GoogleFonts.inter(color: AppColors.textMuted));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeMeds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final med = activeMeds[index];
                      return _prescriptionCard(med.name, med.instruction, med.duration, Colors.teal);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Upcoming Appointments
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upcoming Appointments', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              appointmentsState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, stack) => Text('Error loading appointments: $err'),
                data: (appointments) {
                  final upcoming = appointments.where((a) => a.status == 'Upcoming').toList();
                  if (upcoming.isEmpty) {
                    return Text('No upcoming appointments', style: GoogleFonts.inter(color: AppColors.textMuted));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcoming.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = upcoming[index];
                      // format date
                      final dateStr = "${app.date.day}/${app.date.month}/${app.date.year}";
                      return _appointmentCard(app.doctor.name, app.doctor.specialization, "$dateStr, ${app.timeSlot}", app.hospital);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _prescriptionCard(String medicine, String instruction, String duration, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.medication_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(instruction, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Duration: $duration', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(String doctor, String specialty, String time, String hospital) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(specialty, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(time, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(hospital, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(PatientProfile profile, AsyncValue<List<LabReport>> labReportsState) {
    return Container(
      width: 300,
      color: AppColors.surface,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(profile.healthId, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Vitals
            Text('Health Vitals', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _vitalCard('Blood Pressure', '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic} mmHg', Icons.favorite_rounded, AppColors.danger),
            const SizedBox(height: 8),
            _vitalCard('Blood Glucose', '${profile.vitals.bloodGlucose} mg/dL', Icons.bloodtype_rounded, AppColors.warning),
            const SizedBox(height: 8),
            _vitalCard('Heart Rate', '${profile.vitals.heartRate} bpm', Icons.monitor_heart_rounded, AppColors.success),
            const SizedBox(height: 8),
            _vitalCard('Weight', '${profile.vitals.weight} kg', Icons.scale_rounded, AppColors.info),
            const SizedBox(height: 24),
            // Recent reports
            Text('Recent Test Reports', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            labReportsState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Text('Error loading reports'),
              data: (reports) {
                if (reports.isEmpty) {
                  return Text('No test reports yet', style: GoogleFonts.inter(color: AppColors.textMuted));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
                    return _reportItem(report.testName, dateStr, report.status);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _vitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _reportItem(String name, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: GoogleFonts.inter(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
