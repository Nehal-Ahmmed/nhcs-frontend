import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/patient_repository.dart';
import 'patient_providers.dart';

class BookingState {
  final List<DoctorSpecialist> availableDoctors;
  final DoctorSpecialist? selectedDoctor;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final List<TimeSlot> availableSlots;
  final bool isLoading;
  final Appointment? createdAppointment;
  final String? errorMessage;

  BookingState({
    this.availableDoctors = const [],
    this.selectedDoctor,
    this.selectedDate,
    this.selectedTimeSlot,
    this.availableSlots = const [],
    this.isLoading = false,
    this.createdAppointment,
    this.errorMessage,
  });

  BookingState copyWith({
    List<DoctorSpecialist>? availableDoctors,
    DoctorSpecialist? selectedDoctor,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    List<TimeSlot>? availableSlots,
    bool? isLoading,
    Appointment? createdAppointment,
    String? errorMessage,
  }) {
    return BookingState(
      availableDoctors: availableDoctors ?? this.availableDoctors,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      availableSlots: availableSlots ?? this.availableSlots,
      isLoading: isLoading ?? this.isLoading,
      createdAppointment: createdAppointment ?? this.createdAppointment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  BookingState clearSelection() {
    return BookingState(
      availableDoctors: availableDoctors,
      selectedDoctor: null,
      selectedDate: null,
      selectedTimeSlot: null,
      availableSlots: const [],
      isLoading: false,
      createdAppointment: null,
      errorMessage: null,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final PatientRepository _repository;

  BookingNotifier(this._repository) : super(BookingState()) {
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final doctors = await _repository.getAvailableDoctors();
      state = state.copyWith(availableDoctors: doctors, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectDoctor(DoctorSpecialist doctor) {
    state = state.copyWith(
      selectedDoctor: doctor,
      selectedDate: DateTime.now().add(const Duration(days: 1)),
      selectedTimeSlot: null,
      createdAppointment: null,
      errorMessage: null,
    );
    loadSlots();
  }

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeSlot: null,
      createdAppointment: null,
      errorMessage: null,
    );
    loadSlots();
  }

  Future<void> loadSlots() async {
    if (state.selectedDoctor == null || state.selectedDate == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final slots = await _repository.getAvailableTimeSlots(state.selectedDoctor!.id, state.selectedDate!);
      state = state.copyWith(availableSlots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectSlot(String slot) {
    state = state.copyWith(selectedTimeSlot: slot);
  }

  Future<bool> confirmBooking(String healthId, dynamic ref) async {
    if (state.selectedDoctor == null || state.selectedDate == null || state.selectedTimeSlot == null) {
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final app = await _repository.bookAppointment(
        healthId: healthId,
        doctor: state.selectedDoctor!,
        date: state.selectedDate!,
        timeSlot: state.selectedTimeSlot!,
      );
      state = state.copyWith(isLoading: false, createdAppointment: app);
      
      // Add the new appointment to the listing provider directly
      ref.read(patientAppointmentsProvider.notifier).addAppointment(app);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = state.clearSelection();
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repo = ref.read(patientRepositoryProvider);
  return BookingNotifier(repo);
});
