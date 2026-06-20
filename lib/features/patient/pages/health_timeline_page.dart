import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/health_event.dart';
import '../presentation/providers/patient_providers.dart';

class HealthTimelinePage extends ConsumerStatefulWidget {
  const HealthTimelinePage({super.key});

  @override
  ConsumerState<HealthTimelinePage> createState() => _HealthTimelinePageState();
}

class _HealthTimelinePageState extends ConsumerState<HealthTimelinePage> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(patientTimelineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Health Timeline', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                _filterChip('All'),
                const SizedBox(width: 8),
                _filterChip('Consultations'),
                const SizedBox(width: 8),
                _filterChip('Lab Tests'),
                const SizedBox(width: 8),
                _filterChip('Imaging'),
              ],
            ),
          ),
          Expanded(
            child: timelineState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Center(child: Text('Error loading timeline: $err')),
              data: (events) {
                // Apply Filter
                final filtered = events.where((e) {
                  if (_activeFilter == 'All') return true;
                  if (_activeFilter == 'Consultations') return e.type == HealthEventType.consultation;
                  if (_activeFilter == 'Lab Tests') return e.type == HealthEventType.labTest;
                  if (_activeFilter == 'Imaging') return e.type == HealthEventType.imaging;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text('No matching health events found.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                // Group by year
                final Map<String, List<HealthEvent>> grouped = {};
                for (var event in filtered) {
                  final year = event.date.year.toString();
                  grouped.putIfAbsent(year, () => []).add(event);
                }

                final sortedYears = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: sortedYears.length,
                  itemBuilder: (context, index) {
                    final year = sortedYears[index];
                    final yearEvents = grouped[year]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _yearLabel(year),
                        ...yearEvents.asMap().entries.map((entry) {
                          final eventIndex = entry.key;
                          final event = entry.value;
                          final isFirst = eventIndex == 0;
                          final isLast = eventIndex == yearEvents.length - 1;

                          return _buildTimelineItem(event, isFirst: isFirst, isLast: isLast);
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _activeFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _yearLabel(String year) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(year, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildTimelineItem(HealthEvent event, {required bool isFirst, required bool isLast}) {
    final iconData = _getEventIcon(event.type);
    final themeColor = _getEventColor(event.type);
    final dateStr = "${event.date.day} ${_getMonthName(event.date.month)} ${event.date.year}";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 12, color: AppColors.divider),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor, width: 2),
                  ),
                  child: Icon(iconData, size: 14, color: themeColor),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.divider)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(event.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15))),
                      Text(dateStr, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(event.description, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('${event.doctorName} • ${event.hospitalName}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(HealthEventType type) {
    switch (type) {
      case HealthEventType.consultation:
        return Icons.medical_services_rounded;
      case HealthEventType.labTest:
        return Icons.science_rounded;
      case HealthEventType.imaging:
        return Icons.description_outlined;
      case HealthEventType.surgery:
        return Icons.local_hospital_rounded;
      case HealthEventType.admission:
        return Icons.meeting_room_rounded;
      case HealthEventType.discharge:
        return Icons.logout_rounded;
      case HealthEventType.vaccination:
        return Icons.vaccines_rounded;
      case HealthEventType.prescription:
        return Icons.medication_rounded;
      case HealthEventType.followUp:
        return Icons.event_note_rounded;
      case HealthEventType.emergency:
        return Icons.flash_on_rounded;
    }
  }

  Color _getEventColor(HealthEventType type) {
    switch (type) {
      case HealthEventType.consultation:
        return AppColors.primary;
      case HealthEventType.labTest:
        return AppColors.secondary;
      case HealthEventType.imaging:
        return AppColors.warning;
      case HealthEventType.surgery:
        return Colors.red;
      case HealthEventType.admission:
        return Colors.purple;
      case HealthEventType.discharge:
        return Colors.blue;
      case HealthEventType.vaccination:
        return AppColors.success;
      case HealthEventType.prescription:
        return Colors.teal;
      case HealthEventType.followUp:
        return Colors.orange;
      case HealthEventType.emergency:
        return Colors.redAccent;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
