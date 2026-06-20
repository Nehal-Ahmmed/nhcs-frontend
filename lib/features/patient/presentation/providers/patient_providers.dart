import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/appointment.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/health_event.dart';
import '../../data/models/medical_record.dart';
import '../../data/models/patient_profile.dart';
import '../../data/repositories/patient_repository.dart';

// 1. Patient Repository Provider
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl();
});

// A constant mock health ID for current logged-in patient
const String _currentPatientHealthId = 'NUD-892-441-X7';

// 2. Dashboard Summary Provider
final patientDashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getDashboardSummary(_currentPatientHealthId);
});

// 3. AI Health Summary Provider
final patientAiHealthSummaryProvider = FutureProvider<AiHealthSummary>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getAiHealthSummary(_currentPatientHealthId);
});

// 4. Patient Profile State Provider
class PatientProfileNotifier extends StateNotifier<AsyncValue<PatientProfile>> {
  final PatientRepository _repository;
  final String _healthId;

  PatientProfileNotifier(this._repository, this._healthId) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getPatientProfile(_healthId);
      state = AsyncValue.data(profile);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<bool> updateProfile(PatientProfile updatedProfile) async {
    try {
      state = const AsyncValue.loading();
      final profile = await _repository.updatePatientProfile(_healthId, updatedProfile);
      state = AsyncValue.data(profile);
      return true;
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
      return false;
    }
  }
}

final patientProfileProvider = StateNotifierProvider<PatientProfileNotifier, AsyncValue<PatientProfile>>((ref) {
  final repo = ref.read(patientRepositoryProvider);
  return PatientProfileNotifier(repo, _currentPatientHealthId);
});

// 5. Health Timeline Provider
final patientTimelineProvider = FutureProvider<List<HealthEvent>>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getHealthEvents(_currentPatientHealthId);
});

// 6. Appointments Provider
class PatientAppointmentsNotifier extends StateNotifier<AsyncValue<List<Appointment>>> {
  final PatientRepository _repository;
  final String _healthId;

  PatientAppointmentsNotifier(this._repository, this._healthId) : super(const AsyncValue.loading()) {
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAppointments(_healthId);
      state = AsyncValue.data(List.from(list));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _repository.cancelAppointment(appointmentId);
      await loadAppointments();
    } catch (_) {
      // Maintain data state on error
    }
  }

  void addAppointment(Appointment app) {
    state.whenData((list) {
      state = AsyncValue.data([app, ...list]);
    });
  }
}

final patientAppointmentsProvider = StateNotifierProvider<PatientAppointmentsNotifier, AsyncValue<List<Appointment>>>((ref) {
  final repo = ref.read(patientRepositoryProvider);
  return PatientAppointmentsNotifier(repo, _currentPatientHealthId);
});

// 7. Prescriptions Provider
final patientPrescriptionsProvider = FutureProvider<List<Prescription>>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getPrescriptions(_currentPatientHealthId);
});

// 8. Lab Reports Provider
final patientLabReportsProvider = FutureProvider<List<LabReport>>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getLabReports(_currentPatientHealthId);
});

// 9. Imaging Reports Provider
final patientImagingReportsProvider = FutureProvider<List<ImagingReport>>((ref) async {
  final repo = ref.read(patientRepositoryProvider);
  return repo.getImagingReports(_currentPatientHealthId);
});

// 10. Navigation Selection Provider
final patientNavigationProvider = StateProvider<int>((ref) => 0);
