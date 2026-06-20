import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/hospital_dashboard_stats.dart';
import '../../data/models/reception_queue_item.dart';
import '../../data/models/staff_member.dart';
import '../../data/models/lab_test_order.dart';
import '../../data/models/bed_allocation.dart';
import '../../data/models/pharmacy_item.dart';
import '../../data/repositories/hospital_repository.dart';

// Navigation selection provider
final hospitalNavigationProvider = StateProvider<int>((ref) => 0);

// 1. Dashboard Stats Provider
class HospitalDashboardStatsNotifier extends StateNotifier<HospitalDashboardStats> {
  final HospitalRepository _repository;

  HospitalDashboardStatsNotifier(this._repository) : super(HospitalDashboardStats(
    activePatients: 0,
    bedOccupancyRate: 0.0,
    totalBeds: 0,
    occupiedBeds: 0,
    onDutyStaff: 0,
    onDutyDoctors: 0,
    onDutyNurses: 0,
    emergencyIntake: 0,
    criticalCases: 0,
    alerts: [],
    departmentLoads: [],
  )) {
    loadStats();
  }

  void loadStats() async {
    state = await _repository.getDashboardStats();
  }

  void refresh() async {
    state = await _repository.getDashboardStats();
  }
}

final hospitalDashboardStatsProvider = StateNotifierProvider<HospitalDashboardStatsNotifier, HospitalDashboardStats>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return HospitalDashboardStatsNotifier(repo);
});

// 2. Reception Queue Provider
class ReceptionQueueNotifier extends StateNotifier<List<ReceptionQueueItem>> {
  final HospitalRepository _repository;
  final Ref _ref;

  ReceptionQueueNotifier(this._repository, this._ref) : super([]) {
    loadQueue();
  }

  void loadQueue() async {
    state = await _repository.getReceptionQueue();
  }

  Future<void> checkInPatient({
    required String name,
    required String age,
    required String gender,
    required String healthId,
    required String dept,
    required String doctor,
  }) async {
    await _repository.checkInPatient(name, age, gender, healthId, dept, doctor);
    state = await _repository.getReceptionQueue();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }

  Future<void> updateStatus(String queueNo, String newStatus) async {
    await _repository.updateQueueStatus(queueNo, newStatus);
    state = await _repository.getReceptionQueue();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }
}

final receptionQueueProvider = StateNotifierProvider<ReceptionQueueNotifier, List<ReceptionQueueItem>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return ReceptionQueueNotifier(repo, ref);
});

// 3. Staff Roster Provider
class StaffRosterNotifier extends StateNotifier<List<StaffMember>> {
  final HospitalRepository _repository;

  StaffRosterNotifier(this._repository) : super([]) {
    loadStaff();
  }

  void loadStaff() async {
    state = await _repository.getStaffMembers();
  }

  Future<void> updateShift(String staffId, String day, String newShift) async {
    await _repository.updateStaffShift(staffId, day, newShift);
    state = await _repository.getStaffMembers();
  }

  Future<void> addStaffMember(StaffMember staff) async {
    await _repository.addStaffMember(staff);
    state = await _repository.getStaffMembers();
  }
}

final staffRosterProvider = StateNotifierProvider<StaffRosterNotifier, List<StaffMember>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return StaffRosterNotifier(repo);
});

// 4. Doctor Verifications Provider
class DoctorVerificationsNotifier extends StateNotifier<List<DoctorVerificationRequest>> {
  final HospitalRepository _repository;
  final Ref _ref;

  DoctorVerificationsNotifier(this._repository, this._ref) : super([]) {
    loadRequests();
  }

  void loadRequests() async {
    state = await _repository.getDoctorVerificationRequests();
  }

  Future<void> verifyDoctor(String requestId, bool approve) async {
    String status = approve ? 'Approved' : 'Rejected';
    await _repository.verifyDoctorRequest(requestId, status);
    state = await _repository.getDoctorVerificationRequests();
    
    // Refresh active staff list and dashboard stats
    _ref.read(staffRosterProvider.notifier).loadStaff();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }
}

final doctorVerificationsProvider = StateNotifierProvider<DoctorVerificationsNotifier, List<DoctorVerificationRequest>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return DoctorVerificationsNotifier(repo, ref);
});

// 5. Laboratory Queue Provider
class LaboratoryQueueNotifier extends StateNotifier<List<LabTestOrder>> {
  final HospitalRepository _repository;
  final Ref _ref;

  LaboratoryQueueNotifier(this._repository, this._ref) : super([]) {
    loadOrders();
  }

  void loadOrders() async {
    state = await _repository.getLabTestOrders();
  }

  Future<void> advanceStage(String orderId, {Map<String, String>? results}) async {
    await _repository.advanceLabOrder(orderId, results);
    state = await _repository.getLabTestOrders();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }
}

final laboratoryQueueProvider = StateNotifierProvider<LaboratoryQueueNotifier, List<LabTestOrder>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return LaboratoryQueueNotifier(repo, ref);
});

// 6. Bed Capacity Provider
class BedCapacityNotifier extends StateNotifier<List<BedAllocation>> {
  final HospitalRepository _repository;
  final Ref _ref;

  BedCapacityNotifier(this._repository, this._ref) : super([]) {
    loadBeds();
  }

  void loadBeds() async {
    state = await _repository.getBedAllocations();
  }

  Future<void> admitPatient(String bedId, String patientName, String healthId, String doctor) async {
    await _repository.admitPatientToBed(bedId, patientName, healthId, doctor);
    state = await _repository.getBedAllocations();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }

  Future<void> dischargePatient(String bedId) async {
    await _repository.dischargePatientFromBed(bedId);
    state = await _repository.getBedAllocations();
    _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
  }
}

final bedCapacityProvider = StateNotifierProvider<BedCapacityNotifier, List<BedAllocation>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return BedCapacityNotifier(repo, ref);
});

// 7. Pharmacy Inventory Provider
class PharmacyInventoryNotifier extends StateNotifier<List<PharmacyItem>> {
  final HospitalRepository _repository;
  final Ref _ref;

  PharmacyInventoryNotifier(this._repository, this._ref) : super([]) {
    loadInventory();
  }

  void loadInventory() async {
    state = await _repository.getPharmacyItems();
  }

  Future<bool> dispensePrescription(String rxId) async {
    bool success = await _repository.dispenseDrugs(rxId);
    if (success) {
      state = await _repository.getPharmacyItems();
      _ref.read(hospitalDashboardStatsProvider.notifier).refresh();
    }
    return success;
  }
}

final pharmacyInventoryProvider = StateNotifierProvider<PharmacyInventoryNotifier, List<PharmacyItem>>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return PharmacyInventoryNotifier(repo, ref);
});
