import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/doctor_providers.dart';
import '../presentation/providers/clinical_workspace_provider.dart';
import '../data/models/report_review_item.dart';

class ReportReviewPage extends ConsumerStatefulWidget {
  const ReportReviewPage({super.key});

  @override
  ConsumerState<ReportReviewPage> createState() => _ReportReviewPageState();
}

class _ReportReviewPageState extends ConsumerState<ReportReviewPage> {
  String _activeFilter = 'Pending'; // Pending, Reviewed, All

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(pendingReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header & Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Report Review Portal', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                _filterChip('All', _activeFilter == 'All'),
                const SizedBox(width: 8),
                _filterChip('Pending', _activeFilter == 'Pending'),
                const SizedBox(width: 8),
                _filterChip('Reviewed', _activeFilter == 'Reviewed'),
              ],
            ),
          ),
          
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                // Filter the reports locally based on active tab
                final filtered = reports.where((r) {
                  if (_activeFilter == 'Pending') return r.status == 'Pending';
                  if (_activeFilter == 'Reviewed') return r.status == 'Reviewed';
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found in this category',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All caught up! Excellent work maintaining patient care records.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final report = filtered[index];
                    return _reportCard(context, ref, report);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading reports: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected) {
    return InkWell(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _reportCard(BuildContext context, WidgetRef ref, ReportReviewItem report) {
    final bool isPending = report.status == 'Pending';

    Color trendColor = AppColors.success;
    if (report.trendStatus == 'Worsening') trendColor = AppColors.danger;
    if (report.trendStatus == 'Stable') trendColor = AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.warning.withOpacity(0.3) : AppColors.divider.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    report.patientName[0],
                    style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.patientName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${report.testName} • ID: ${report.healthId}',
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ordered: ${report.orderedDate.day}/${report.orderedDate.month}/${report.orderedDate.year}',
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isPending ? AppColors.warning : AppColors.success).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.status,
                      style: GoogleFonts.inter(
                        color: isPending ? AppColors.warning : AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI Assisted comparison & values
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Test Parameters & Results', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    if (report.trendSummary.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: trendColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            Icon(
                              report.trendStatus == 'Improving' 
                                  ? Icons.trending_down_rounded 
                                  : report.trendStatus == 'Worsening' 
                                      ? Icons.trending_up_rounded 
                                      : Icons.trending_flat_rounded,
                              size: 14,
                              color: trendColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trend: ${report.trendStatus}',
                              style: GoogleFonts.inter(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (report.trendSummary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'AI Trend Assessment: ${report.trendSummary}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Grid of values
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 10,
                    childAspectRatio: 5.5,
                  ),
                  itemCount: report.results.length,
                  itemBuilder: (context, idx) {
                    final key = report.results.keys.elementAt(idx);
                    final val = report.results[key];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(key, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        Text(val ?? '', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showFullReportDetailsDialog(context, report),
                  icon: const Icon(Icons.zoom_in_rounded, size: 16),
                  label: const Text('View Full Report'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Start consultation directly from report review
                    ref.read(clinicalWorkspaceProvider.notifier).initializePatient(report.healthId, report.patientName);
                    ref.read(doctorNavigationProvider.notifier).state = 1;
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Open Workspace'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(pendingReportsProvider.notifier).reviewReport(report.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report for ${report.patientName} marked as Reviewed.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Mark Reviewed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showFullReportDetailsDialog(BuildContext context, ReportReviewItem report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.science_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Detailed Diagnostics Report', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogInfoRow('Patient Name:', report.patientName),
                  _dialogInfoRow('Health ID:', report.healthId),
                  _dialogInfoRow('Investigation:', report.testName),
                  _dialogInfoRow('Category:', report.category),
                  _dialogInfoRow('Ordered Date:', '${report.orderedDate.day}/${report.orderedDate.month}/${report.orderedDate.year}'),
                  const Divider(height: 24),
                  Text('Lab Readings & Values:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: report.results.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: GoogleFonts.inter(fontSize: 12)),
                              Text(e.value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('AI Interpretation:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent)),
                  const SizedBox(height: 6),
                  Text(
                    'Comparative analysis with history shows ${report.trendSummary}. Patient medication compliance should be checked. If parameters do not stabilize, please review the clinical medication dosage.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
