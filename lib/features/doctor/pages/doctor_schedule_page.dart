import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/doctor_providers.dart';

class DoctorSchedulePage extends ConsumerStatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  ConsumerState<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends ConsumerState<DoctorSchedulePage> {
  String _selectedDay = 'Monday';
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    // Watch slots for the selected day
    final slotsAsync = ref.watch(doctorScheduleProvider(_selectedDay));

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
                Text('My Schedule', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () {}),
                Text('June 2026', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () {}),
              ],
            ),
          ),
          
          // Weekdays Strip Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: _weekdays.map((day) {
                final isSelected = _selectedDay == day;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? null 
                            : Border.all(color: AppColors.divider.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day.substring(0, 3),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white70 : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDateForDay(day),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),
          
          Expanded(
            child: slotsAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return const Center(child: Text('No slots scheduled for this day.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final patient = _getPatientForSlot(_selectedDay, slot);
                    
                    return _scheduleItem(
                      slot,
                      patient['name']!,
                      patient['type']!,
                      patient['dept']!,
                      isEmpty: patient['name'] == 'Available Slot',
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading schedule: $err')),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateForDay(String day) {
    switch (day) {
      case 'Monday':
        return '16';
      case 'Tuesday':
        return '17';
      case 'Wednesday':
        return '18';
      case 'Thursday':
        return '19';
      case 'Friday':
        return '20';
      default:
        return '16';
    }
  }

  Map<String, String> _getPatientForSlot(String day, String slot) {
    if (day == 'Monday') {
      if (slot == '08:00 AM') {
        return {'name': 'Rahim Islam', 'type': 'Follow-up', 'dept': 'Cardiology'};
      }
      if (slot == '08:30 AM') {
        return {'name': 'Karim Ullah', 'type': 'Referral', 'dept': 'Cardiology'};
      }
      if (slot == '09:00 AM') {
        return {'name': 'Tahmina Akhtar', 'type': 'First Consultation', 'dept': 'Cardiology'};
      }
      if (slot == '09:30 AM') {
        return {'name': 'Abdul Khalek', 'type': 'Emergency', 'dept': 'Cardiology'};
      }
    }
    
    // Default fallback to available
    return {'name': 'Available Slot', 'type': '', 'dept': ''};
  }

  Widget _scheduleItem(String time, String patient, String type, String dept, {bool isEmpty = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.surface.withOpacity(0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEmpty ? AppColors.divider.withOpacity(0.5) : AppColors.divider,
        ),
        boxShadow: isEmpty ? null : [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)],
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 100,
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          if (!isEmpty) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Center(
                child: Text(
                  patient[0],
                  style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(type, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(6)),
              child: Text(
                dept,
                style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            const Icon(Icons.event_available_rounded, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Available Slot — Click to block',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
