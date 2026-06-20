import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/hospital_mock_datasource.dart';
import '../models/hospital_dashboard_stats.dart';
import '../models/reception_queue_item.dart';
import '../models/staff_member.dart';
import '../models/lab_test_order.dart';
import '../models/bed_allocation.dart';
import '../models/pharmacy_item.dart';

abstract class HospitalRepository {
  Future<HospitalDashboardStats> getDashboardStats();
  Future<List<ReceptionQueueItem>> getReceptionQueue();
  Future<List<StaffMember>> getStaffMembers();
  Future<List<DoctorVerificationRequest>> getDoctorVerificationRequests();
  Future<List<LabTestOrder>> getLabTestOrders();
  Future<List<BedAllocation>> getBedAllocations();
  Future<List<PharmacyItem>> getPharmacyItems();
  Future<Map<String, dynamic>?> getPrescriptionById(String rxId);

  Future<void> checkInPatient(String name, String age, String gender, String healthId, String dept, String doctor);
  Future<void> updateQueueStatus(String queueNo, String newStatus);
  Future<void> updateStaffShift(String staffId, String day, String newShift);
  Future<void> verifyDoctorRequest(String requestId, String status);
  Future<void> advanceLabOrder(String orderId, Map<String, String>? results);
  Future<void> admitPatientToBed(String bedId, String patientName, String healthId, String doctor);
  Future<void> dischargePatientFromBed(String bedId);
  Future<bool> dispenseDrugs(String rxId);
  Future<void> addStaffMember(StaffMember staff);
}

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalMockDatasource _datasource;

  HospitalRepositoryImpl(this._datasource);

  @override
  Future<void> addStaffMember(StaffMember staff) async {
    _datasource.staffMembers.add(staff);
  }

  @override
  Future<HospitalDashboardStats> getDashboardStats() async {
    return _datasource.dashboardStats;
  }

  @override
  Future<List<ReceptionQueueItem>> getReceptionQueue() async {
    return _datasource.receptionQueue;
  }

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    return _datasource.staffMembers;
  }

  @override
  Future<List<DoctorVerificationRequest>> getDoctorVerificationRequests() async {
    return _datasource.verificationRequests;
  }

  @override
  Future<List<LabTestOrder>> getLabTestOrders() async {
    return _datasource.labOrders;
  }

  @override
  Future<List<BedAllocation>> getBedAllocations() async {
    return _datasource.beds;
  }

  @override
  Future<List<PharmacyItem>> getPharmacyItems() async {
    return _datasource.pharmacyItems;
  }

  @override
  Future<Map<String, dynamic>?> getPrescriptionById(String rxId) async {
    return _datasource.mockPrescriptions[rxId];
  }

  @override
  Future<void> checkInPatient(String name, String age, String gender, String healthId, String dept, String doctor) async {
    final String prefix = dept == 'Emergency' ? 'EM' : 'CD';
    final int nextNo = _datasource.receptionQueue.where((p) => p.dept == dept).length + 1;
    final newItem = ReceptionQueueItem(
      queueNo: '$prefix-${nextNo.toString().padLeft(2, '0')}',
      name: name,
      age: age,
      gender: gender,
      dept: dept,
      doctor: doctor,
      status: 'Waiting',
    );
    _datasource.receptionQueue.add(newItem);
    
    // Increment active patients stats
    _datasource.dashboardStats = _datasource.dashboardStats.copyWith(
      activePatients: _datasource.dashboardStats.activePatients + 1,
    );
  }

  @override
  Future<void> updateQueueStatus(String queueNo, String newStatus) async {
    final idx = _datasource.receptionQueue.indexWhere((p) => p.queueNo == queueNo);
    if (idx != -1) {
      _datasource.receptionQueue[idx] = _datasource.receptionQueue[idx].copyWith(status: newStatus);
    }
  }

  @override
  Future<void> updateStaffShift(String staffId, String day, String newShift) async {
    final idx = _datasource.staffMembers.indexWhere((s) => s.id == staffId);
    if (idx != -1) {
      final updatedShifts = Map<String, String>.from(_datasource.staffMembers[idx].shifts);
      updatedShifts[day] = newShift;
      _datasource.staffMembers[idx] = _datasource.staffMembers[idx].copyWith(shifts: updatedShifts);
    }
  }

  @override
  Future<void> verifyDoctorRequest(String requestId, String status) async {
    final idx = _datasource.verificationRequests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _datasource.verificationRequests[idx] = _datasource.verificationRequests[idx].copyWith(status: status);
      if (status == 'Approved') {
        final req = _datasource.verificationRequests[idx];
        final newDoc = StaffMember(
          id: 'S-00${_datasource.staffMembers.length + 1}',
          name: req.name,
          role: 'Doctor',
          dept: req.specialization,
          status: 'Active',
          shifts: {'Monday': '8 AM - 2 PM'},
        );
        _datasource.staffMembers.add(newDoc);
        
        // Update stats
        _datasource.dashboardStats = _datasource.dashboardStats.copyWith(
          onDutyStaff: _datasource.dashboardStats.onDutyStaff + 1,
          onDutyDoctors: _datasource.dashboardStats.onDutyDoctors + 1,
        );
      }
    }
  }

  @override
  Future<void> advanceLabOrder(String orderId, Map<String, String>? results) async {
    final idx = _datasource.labOrders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _datasource.labOrders[idx];
      String nextStatus = current.status;
      Map<String, String> updatedResults = Map.from(current.results);

      if (current.status == 'Ordered') {
        nextStatus = 'Sample Collected';
      } else if (current.status == 'Sample Collected') {
        nextStatus = 'Processing';
      } else if (current.status == 'Processing') {
        if (results != null) {
          updatedResults = results;
        }
        nextStatus = 'Verified';
      } else if (current.status == 'Verified') {
        nextStatus = 'Published';
      }

      _datasource.labOrders[idx] = current.copyWith(
        status: nextStatus,
        results: updatedResults,
      );
    }
  }

  @override
  Future<void> admitPatientToBed(String bedId, String patientName, String healthId, String doctor) async {
    final idx = _datasource.beds.indexWhere((b) => b.id == bedId);
    if (idx != -1) {
      _datasource.beds[idx] = _datasource.beds[idx].copyWith(
        status: 'Occupied',
        patient: patientName,
        healthId: healthId,
        doctor: doctor,
        days: 0,
      );
      _datasource.updateOccupancyStats();
    }
  }

  @override
  Future<void> dischargePatientFromBed(String bedId) async {
    final idx = _datasource.beds.indexWhere((b) => b.id == bedId);
    if (idx != -1) {
      _datasource.beds[idx] = _datasource.beds[idx].copyWith(
        status: 'Available',
        clearPatientData: true,
      );
      _datasource.updateOccupancyStats();
    }
  }

  @override
  Future<bool> dispenseDrugs(String rxId) async {
    final rx = _datasource.mockPrescriptions[rxId];
    if (rx == null) return false;
    final List items = rx['items'];

    // Stock check
    for (var item in items) {
      final String medName = item['medicine'];
      final int qty = item['qty'];
      final idx = _datasource.pharmacyItems.indexWhere((i) => i.name == medName);
      if (idx == -1 || _datasource.pharmacyItems[idx].stock < qty) {
        return false;
      }
    }

    // Deduct stock
    for (var item in items) {
      final String medName = item['medicine'];
      final int qty = item['qty'];
      final idx = _datasource.pharmacyItems.indexWhere((i) => i.name == medName);
      if (idx != -1) {
        final current = _datasource.pharmacyItems[idx];
        _datasource.pharmacyItems[idx] = current.copyWith(stock: current.stock - qty);
      }
    }

    // Check if low stock triggers alerts
    final paracetamolLow = _datasource.pharmacyItems.firstWhere((i) => i.name.startsWith('Paracetamol')).stock < 1000;
    
    // Dynamic alerts list
    final updatedAlerts = List<OperationalAlert>.from(_datasource.dashboardStats.alerts);
    final paracetamolAlertIdx = updatedAlerts.indexWhere((a) => a.title == 'Medicine Shortage');
    if (paracetamolLow && paracetamolAlertIdx == -1) {
      updatedAlerts.add(OperationalAlert(
        id: 'a4',
        title: 'Medicine Shortage',
        description: 'Paracetamol stock is critical.',
        timeAgo: 'Just now',
        type: 'warning',
      ));
    } else if (!paracetamolLow && paracetamolAlertIdx != -1) {
      updatedAlerts.removeAt(paracetamolAlertIdx);
    }
    
    _datasource.dashboardStats = _datasource.dashboardStats.copyWith(alerts: updatedAlerts);
    return true;
  }
}

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepositoryImpl(HospitalMockDatasource());
});
