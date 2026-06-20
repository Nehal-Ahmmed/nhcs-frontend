import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/medical_record.dart';
import '../presentation/providers/patient_providers.dart';

class MedicalVaultPage extends ConsumerWidget {
  const MedicalVaultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsState = ref.watch(patientPrescriptionsProvider);
    final labReportsState = ref.watch(patientLabReportsProvider);
    final imagingState = ref.watch(patientImagingReportsProvider);

    return DefaultTabController(
      length: 3,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medical Vault', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('All your medical records in one secure place', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Prescriptions'),
                      Tab(text: 'Lab Reports'),
                      Tab(text: 'Imaging'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrescriptionsTab(context, prescriptionsState),
                  _buildLabReportsTab(context, labReportsState),
                  _buildImagingTab(context, imagingState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsTab(BuildContext context, AsyncValue<List<Prescription>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(child: Text('Error loading prescriptions: $err')),
      data: (prescriptions) {
        if (prescriptions.isEmpty) {
          return Center(child: Text('No prescriptions found.', style: GoogleFonts.inter(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: prescriptions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final prescription = prescriptions[index];
            final dateStr = "${prescription.date.day}/${prescription.date.month}/${prescription.date.year}";
            return _buildPrescriptionCard(context, prescription, dateStr);
          },
        );
      },
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, Prescription p, String dateStr) {
    final followUpText = p.followUpDate != null ? 'Follow-up: ${p.followUpDate}' : 'No follow-up scheduled';

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.diagnosis, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('${p.doctorName} • ${p.doctorSpecialization}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text(dateStr, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.medicines.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(8)),
              child: Text('${m.name} ${m.dosage}', style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(followUpText, style: GoogleFonts.inter(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _viewPrescriptionDetails(context, p),
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('View details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabReportsTab(BuildContext context, AsyncValue<List<LabReport>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(child: Text('Error loading lab reports: $err')),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(child: Text('No lab reports found.', style: GoogleFonts.inter(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildLabReportCard(context, report, dateStr);
          },
        );
      },
    );
  }

  Widget _buildLabReportCard(BuildContext context, LabReport report, String dateStr) {
    final statusColor = report.status == 'Published' ? AppColors.success : AppColors.warning;
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
            decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.science_rounded, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.testName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Category: ${report.category} • $dateStr', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(report.status, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          if (report.status == 'Published') ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.visibility_rounded, size: 18, color: AppColors.primary),
              onPressed: () => _viewLabReportDetails(context, report),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagingTab(BuildContext context, AsyncValue<List<ImagingReport>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(child: Text('Error loading imaging reports: $err')),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(child: Text('No imaging reports found.', style: GoogleFonts.inter(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";
            return _buildImagingReportCard(context, report, dateStr);
          },
        );
      },
    );
  }

  Widget _buildImagingReportCard(BuildContext context, ImagingReport report, String dateStr) {
    final iconData = report.type.contains('X-Ray') ? Icons.image_outlined : Icons.monitor_heart_rounded;
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
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(iconData, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.type, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${report.hospitalName} • $dateStr', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
            child: Text('Reported', style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.visibility_rounded, size: 18, color: AppColors.primary),
            onPressed: () => _viewImagingReportDetails(context, report),
          ),
        ],
      ),
    );
  }

  void _viewPrescriptionDetails(BuildContext context, Prescription p) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 650,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prescription Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.doctorName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      Text(p.doctorSpecialization, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      Text(p.hospitalName, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  Text("${p.date.day}/${p.date.month}/${p.date.year}", style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Diagnosis: ${p.diagnosis}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 16),
              Text('Medicines:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: p.medicines.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final med = p.medicines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Text('${med.name} (${med.dosage})', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Spacer(),
                              Text(med.duration, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text(med.instruction, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (p.clinicalNotes.isNotEmpty) ...[
                Text('Clinical Notes:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(p.clinicalNotes, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prescription PDF download initiated.'), backgroundColor: AppColors.success),
                      );
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download PDF'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewLabReportDetails(BuildContext context, LabReport report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 750,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lab Report Result', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.testName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
                      Text('Prescribed by: ${report.doctorName}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                      Text('Facility: ${report.hospitalName}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  Text("${report.date.day}/${report.date.month}/${report.date.year}", style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              // AI health warning banner if FBG is high
              if (report.aiInterpretation.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Clinical Insight', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade900)),
                            const SizedBox(height: 4),
                            Text(report.aiInterpretation, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Results table header
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Parameter', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(child: Text('Value', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(child: Text('Unit', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text('Ref. Range', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Results rows
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: report.results.length,
                  itemBuilder: (context, index) {
                    final res = report.results[index];
                    final isAbnormal = res.status != 'Normal';
                    final valColor = isAbnormal ? AppColors.danger : AppColors.textPrimary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(res.parameter, style: GoogleFonts.inter(fontSize: 13))),
                          Expanded(
                            child: Text(
                              res.value,
                              style: GoogleFonts.inter(
                                fontSize: 13, 
                                fontWeight: isAbnormal ? FontWeight.bold : FontWeight.normal,
                                color: valColor,
                              ),
                            ),
                          ),
                          Expanded(child: Text(res.unit, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted))),
                          Expanded(
                            flex: 2, 
                            child: Row(
                              children: [
                                Text(res.referenceRange, style: GoogleFonts.inter(fontSize: 13)),
                                if (isAbnormal) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(4)),
                                    child: Text('High', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report data exported to CSV.'), backgroundColor: AppColors.success),
                      );
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share/Export'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewImagingReportDetails(BuildContext context, ImagingReport report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan view panel
              Expanded(
                flex: 11,
                child: Container(
                  height: 480,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            report.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 56),
                                  const SizedBox(height: 12),
                                  Text('Scan Image Placeholder', style: GoogleFonts.inter(color: Colors.white38)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${report.type} (SECURE MOCK)',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Text reports details
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Imaging Findings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const Divider(),
                    Text('Exam Details:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text('Body Part: ${report.bodyPart}', style: GoogleFonts.inter(fontSize: 13)),
                    Text('Facility: ${report.hospitalName}', style: GoogleFonts.inter(fontSize: 13)),
                    Text('Referrer: ${report.doctorName}', style: GoogleFonts.inter(fontSize: 13)),
                    Text('Date: ${report.date.day}/${report.date.month}/${report.date.year}', style: GoogleFonts.inter(fontSize: 13)),
                    const SizedBox(height: 16),
                    Text('Findings:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          report.findings,
                          style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Impression:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        report.impression,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
