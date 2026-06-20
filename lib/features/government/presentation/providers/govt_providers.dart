import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/govt_dashboard_stats.dart';
import '../../data/models/govt_registry_models.dart';
import '../../data/models/govt_resource_models.dart';
import '../../data/models/govt_audit_event.dart';
import '../../data/repositories/govt_repository.dart';

// Navigation selection provider
final govtNavigationProvider = StateProvider<int>((ref) => 0);

// 1. Dashboard Stats Provider
class GovtDashboardStatsNotifier extends StateNotifier<GovtDashboardStats> {
  final GovtRepository _repository;

  GovtDashboardStatsNotifier(this._repository) : super(const GovtDashboardStats(
    totalRegisteredCitizens: 0,
    totalRegisteredDoctors: 0,
    totalLicensedHospitals: 0,
    activeDiseaseOutbreaks: 0,
    nationalBedOccupancyRate: 0.0,
    alerts: [],
    outbreaks: [],
  )) {
    loadStats();
  }

  void loadStats() async {
    state = await _repository.getDashboardStats();
  }

  void refresh() async {
    state = await _repository.getDashboardStats();
  }

  Future<void> issueOutbreakAlert({
    required String diseaseName,
    required String title,
    required String description,
    required String riskLevel,
    required String division,
  }) async {
    await _repository.issueOutbreakAlert(diseaseName, title, description, riskLevel, division);
    state = await _repository.getDashboardStats();
  }
}

final govtDashboardStatsProvider = StateNotifierProvider<GovtDashboardStatsNotifier, GovtDashboardStats>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtDashboardStatsNotifier(repo);
});

// 2. Citizen Registry Provider
class GovtCitizenRegistryNotifier extends StateNotifier<List<CitizenProfile>> {
  final GovtRepository _repository;

  GovtCitizenRegistryNotifier(this._repository) : super([]) {
    loadCitizens();
  }

  void loadCitizens() async {
    state = await _repository.getCitizens();
  }
}

final govtCitizenRegistryProvider = StateNotifierProvider<GovtCitizenRegistryNotifier, List<CitizenProfile>>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtCitizenRegistryNotifier(repo);
});

// 3. Doctor Registry Provider
class GovtDoctorRegistryNotifier extends StateNotifier<List<DoctorProfile>> {
  final GovtRepository _repository;
  final Ref _ref;

  GovtDoctorRegistryNotifier(this._repository, this._ref) : super([]) {
    loadDoctors();
  }

  void loadDoctors() async {
    state = await _repository.getDoctors();
  }

  Future<void> updateDoctorStatus(String bmdcId, String status) async {
    await _repository.updateDoctorStatus(bmdcId, status);
    state = await _repository.getDoctors();
    
    // Refresh dashboard stats & audit logs
    _ref.read(govtDashboardStatsProvider.notifier).refresh();
    _ref.read(govtAuditLogsProvider.notifier).loadLogs();
  }
}

final govtDoctorRegistryProvider = StateNotifierProvider<GovtDoctorRegistryNotifier, List<DoctorProfile>>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtDoctorRegistryNotifier(repo, ref);
});

// 4. Hospital Registry Provider
class GovtHospitalRegistryNotifier extends StateNotifier<List<HospitalProfile>> {
  final GovtRepository _repository;
  final Ref _ref;

  GovtHospitalRegistryNotifier(this._repository, this._ref) : super([]) {
    loadHospitals();
  }

  void loadHospitals() async {
    state = await _repository.getHospitals();
  }

  Future<void> auditHospital({
    required String facilityId,
    required double score,
    required String status,
    required String comment,
  }) async {
    await _repository.performHospitalAudit(facilityId, score, status, comment);
    state = await _repository.getHospitals();

    // Refresh dashboard stats, audit logs, and resources map
    _ref.read(govtDashboardStatsProvider.notifier).refresh();
    _ref.read(govtAuditLogsProvider.notifier).loadLogs();
    _ref.read(govtResourcesProvider.notifier).loadResources();
  }
}

final govtHospitalRegistryProvider = StateNotifierProvider<GovtHospitalRegistryNotifier, List<HospitalProfile>>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtHospitalRegistryNotifier(repo, ref);
});

// 5. Regional Resources Provider
class GovtResourcesNotifier extends StateNotifier<List<RegionalResource>> {
  final GovtRepository _repository;

  GovtResourcesNotifier(this._repository) : super([]) {
    loadResources();
  }

  void loadResources() async {
    state = await _repository.getRegionalResources();
  }
}

final govtResourcesProvider = StateNotifierProvider<GovtResourcesNotifier, List<RegionalResource>>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtResourcesNotifier(repo);
});

// 6. Audit Logs Provider
class GovtAuditLogsNotifier extends StateNotifier<List<GovtAuditEvent>> {
  final GovtRepository _repository;

  GovtAuditLogsNotifier(this._repository) : super([]) {
    loadLogs();
  }

  void loadLogs() async {
    state = await _repository.getAuditEvents();
  }
}

final govtAuditLogsProvider = StateNotifierProvider<GovtAuditLogsNotifier, List<GovtAuditEvent>>((ref) {
  final repo = ref.watch(govtRepositoryProvider);
  return GovtAuditLogsNotifier(repo);
});
