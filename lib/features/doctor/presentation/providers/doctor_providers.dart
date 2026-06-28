import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/doctor_dashboard_summary.dart';
import '../../data/models/patient_queue_item.dart';
import '../../data/models/report_review_item.dart';
import '../../data/repositories/doctor_repository.dart';

// Repository Provider
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl();
});

// Navigation Provider
final doctorNavigationProvider = StateProvider<int>((ref) => 0);

// Dashboard Summary Provider
final doctorDashboardProvider = FutureProvider<DoctorDashboardSummary>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getDashboardSummary();
});

// Patient Queue Provider
final patientQueueProvider = FutureProvider<List<PatientQueueItem>>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getPatientQueue();
});

// Pending Reports Notifier & Provider (Allows modifying the list when reviewed)
class PendingReportsNotifier extends StateNotifier<AsyncValue<List<ReportReviewItem>>> {
  final DoctorRepository _repository;

  PendingReportsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    state = const AsyncValue.loading();
    try {
      final reports = await _repository.getPendingReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reviewReport(String reportId) async {
    try {
      await _repository.reviewReport(reportId);
      // Refresh the report list
      final reports = await _repository.getPendingReports();
      state = AsyncValue.data(reports);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pendingReportsProvider = StateNotifierProvider<PendingReportsNotifier, AsyncValue<List<ReportReviewItem>>>((ref) {
  final repository = ref.watch(doctorRepositoryProvider);
  return PendingReportsNotifier(repository);
});

// Schedule slots provider (for a given day)
final doctorScheduleProvider = FutureProvider.family<List<String>, String>((ref, day) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getScheduleSlots(day);
});

// Active patient search provider (to lookup profiles in clinical workspace)
final patientSearchProvider = FutureProvider.family<dynamic, String>((ref, healthId) async {
  if (healthId.isEmpty) return null;
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getPatientProfileByHealthId(healthId);
});
