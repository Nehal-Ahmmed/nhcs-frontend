import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/appointment.dart';
import '../presentation/providers/booking_provider.dart';
import '../presentation/providers/patient_providers.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  String _activeTab = 'Upcoming';
  String _searchQuery = '';
  String _specializationFilter = 'All Specializations';

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(patientAppointmentsProvider);
    final bookingState = ref.watch(bookingProvider);

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
                Text('Appointments Portal', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openBookingDialog(null),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Book New'),
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
                  // Tab selector
                  Row(
                    children: [
                      _tab('Upcoming'),
                      const SizedBox(width: 8),
                      _tab('Past'),
                      const SizedBox(width: 8),
                      _tab('Cancelled'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Appointment listing based on selected tab
                  appointmentsState.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, stack) => Center(child: Text('Error loading appointments: $err')),
                    data: (appointments) {
                      final filtered = appointments.where((a) => a.status == _activeTab).toList();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text('No $_activeTab appointments found.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final app = filtered[index];
                          return _buildAppointmentCard(app);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Find Doctor Section
                  Text('Find a Medical Specialist', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _buildDoctorFilters(),
                  const SizedBox(height: 24),
                  
                  // Doctor list
                  if (bookingState.isLoading && bookingState.availableDoctors.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildDoctorList(bookingState.availableDoctors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label) {
    final active = _activeTab == label;
    return InkWell(
      onTap: () => setState(() => _activeTab = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: active ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment app) {
    final dateStr = "${app.date.day} ${_getMonthName(app.date.month)} ${app.date.year}";
    final statusColor = _getStatusColor(app.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.doctor.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(app.doctor.specialization, style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('$dateStr, ${app.timeSlot}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(app.hospital, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(app.status, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text('Queue: ${app.queueNumber}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              if (app.status == 'Upcoming') ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _confirmCancel(app.id),
                  child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by doctor name or specialization...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.divider)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _specializationFilter,
                items: ['All Specializations', 'Cardiology', 'Endocrinology', 'General Medicine', 'Gynaecology & Obstetrics']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14))))
                    .toList(),
                onChanged: (val) => setState(() => _specializationFilter = val ?? 'All Specializations'),
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorList(List<DoctorSpecialist> doctors) {
    final filtered = doctors.where((doc) {
      final matchesSearch = doc.name.toLowerCase().contains(_searchQuery) ||
          doc.specialization.toLowerCase().contains(_searchQuery);
      final matchesSpecialization = _specializationFilter == 'All Specializations' ||
          doc.specialization.contains(_specializationFilter.split(' ').first);
      return matchesSearch && matchesSpecialization;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('No doctors match your search filters.', style: GoogleFonts.inter(color: AppColors.textMuted)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = filtered[index];
        return _buildDoctorCard(doc);
      },
    );
  }

  Widget _buildDoctorCard(DoctorSpecialist doc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF0EA5E9)]), 
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                Text('${doc.specialization} • ${doc.hospital}', style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${doc.experienceYears} years exp.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Text(' ${doc.rating}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳${doc.consultationFee}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _openBookingDialog(doc),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 13),
                ),
                child: const Text('Book Slot'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancel(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep')),
          ElevatedButton(
            onPressed: () {
              ref.read(patientAppointmentsProvider.notifier).cancelAppointment(appointmentId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _openBookingDialog(DoctorSpecialist? doctor) {
    ref.read(bookingProvider.notifier).reset();
    if (doctor != null) {
      ref.read(bookingProvider.notifier).selectDoctor(doctor);
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _BookingWizardDialog(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return AppColors.primary;
      case 'Past':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
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

class _BookingWizardDialog extends ConsumerStatefulWidget {
  const _BookingWizardDialog();

  @override
  ConsumerState<_BookingWizardDialog> createState() => _BookingWizardDialogState();
}

class _BookingWizardDialogState extends ConsumerState<_BookingWizardDialog> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final isDoctorSelected = bookingState.selectedDoctor != null;

    if (isDoctorSelected && _step == 0) {
      // If doctor was pre-selected, skip Step 0 (Select Doctor)
      _step = 1;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 550,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  bookingState.createdAppointment != null ? 'Booking Confirmed' : 'Book Appointment',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (bookingState.createdAppointment == null)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: bookingState.createdAppointment != null
                  ? _buildSuccessView(bookingState.createdAppointment!)
                  : _buildStepContent(bookingState),
            ),
            if (bookingState.createdAppointment == null) ...[
              const Divider(),
              _buildActionsRow(bookingState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BookingState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_step) {
      case 0:
        return _buildDoctorSelectorStep(state);
      case 1:
        return _buildDateTimeSelectorStep(state);
      case 2:
        return _buildConfirmationStep(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDoctorSelectorStep(BookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Select a Doctor to begin:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: state.availableDoctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = state.availableDoctors[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.divider)),
                title: Text(doc.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('${doc.specialization} • ${doc.hospital}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  ref.read(bookingProvider.notifier).selectDoctor(doc);
                  setState(() => _step = 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectorStep(BookingState state) {
    final next7Days = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Select Date:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: next7Days.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = next7Days[index];
              final isSelected = state.selectedDate != null &&
                  state.selectedDate!.year == date.year &&
                  state.selectedDate!.month == date.month &&
                  state.selectedDate!.day == date.day;

              return InkWell(
                onTap: () => ref.read(bookingProvider.notifier).selectDate(date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekdayName(date.weekday),
                        style: GoogleFonts.inter(color: isSelected ? Colors.white70 : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text('Select Time Slot:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemCount: state.availableSlots.length,
            itemBuilder: (context, index) {
              final slot = state.availableSlots[index];
              final isSelected = state.selectedTimeSlot == slot.time;

              return InkWell(
                onTap: slot.isAvailable 
                    ? () => ref.read(bookingProvider.notifier).selectSlot(slot.time)
                    : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.secondary 
                        : (slot.isAvailable ? AppColors.background : Colors.black12.withOpacity(0.04)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.secondary 
                          : (slot.isAvailable ? AppColors.divider : Colors.transparent),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    slot.time,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Colors.white 
                          : (slot.isAvailable ? AppColors.textPrimary : AppColors.textMuted),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep(BookingState state) {
    final doc = state.selectedDoctor!;
    final dateStr = state.selectedDate != null
        ? "${state.selectedDate!.day} ${_getMonthName(state.selectedDate!.month)} ${state.selectedDate!.year}"
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please review the details below before confirming the booking.',
                  style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _detailRow('Doctor', doc.name),
        _detailRow('Specialization', doc.specialization),
        _detailRow('Hospital', doc.hospital),
        _detailRow('Date', dateStr),
        _detailRow('Time Slot', state.selectedTimeSlot ?? ''),
        _detailRow('Consultation Fee', '৳${doc.consultationFee}', isBold: true),
      ],
    );
  }

  Widget _buildSuccessView(Appointment app) {
    final dateStr = "${app.date.day} ${_getMonthName(app.date.month)} ${app.date.year}";
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, size: 56, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          Text('Appointment Placed!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Your appointment with ${app.doctor.name} has been booked.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _successStat('Queue', app.queueNumber),
                Container(width: 1, height: 32, color: AppColors.divider),
                _successStat('Time', app.timeSlot),
                Container(width: 1, height: 32, color: AppColors.divider),
                _successStat('Date', dateStr),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _successStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BookingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_step > 0)
          OutlinedButton(
            onPressed: () => setState(() => _step--),
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            if (_step < 2)
              ElevatedButton(
                onPressed: (state.selectedDoctor != null && _step == 0) ||
                           (state.selectedDate != null && state.selectedTimeSlot != null && _step == 1)
                    ? () => setState(() => _step++)
                    : null,
                child: const Text('Next'),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  await ref.read(bookingProvider.notifier).confirmBooking('NUD-892-441-X7', ref);
                },
                child: const Text('Confirm Booking'),
              ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayName(int w) {
    const list = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (w >= 1 && w <= 7) return list[w - 1];
    return '';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
