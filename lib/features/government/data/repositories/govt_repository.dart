import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/govt_mock_datasource.dart';
import '../models/govt_dashboard_stats.dart';
import '../models/govt_registry_models.dart';
import '../models/govt_resource_models.dart';
import '../models/govt_audit_event.dart';

abstract class GovtRepository {
  Future<GovtDashboardStats> getDashboardStats();
  Future<List<CitizenProfile>> getCitizens();
  Future<List<DoctorProfile>> getDoctors();
  Future<List<HospitalProfile>> getHospitals();
  Future<List<RegionalResource>> getRegionalResources();
  Future<List<GovtAuditEvent>> getAuditEvents();
  Future<void> updateDoctorStatus(String bmdcId, String status);
  Future<void> performHospitalAudit(String facilityId, double newScore, String status, String comment);
  Future<void> issueOutbreakAlert(String diseaseName, String title, String description, String riskLevel, String division);
}

class GovtRepositoryImpl implements GovtRepository {
  final GovtMockDatasource _datasource;

  GovtRepositoryImpl(this._datasource);

  @override
  Future<GovtDashboardStats> getDashboardStats() async {
    return _datasource.dashboardStats;
  }

  @override
  Future<List<CitizenProfile>> getCitizens() async {
    return _datasource.citizens;
  }

  @override
  Future<List<DoctorProfile>> getDoctors() async {
    return _datasource.doctors;
  }

  @override
  Future<List<HospitalProfile>> getHospitals() async {
    return _datasource.hospitals;
  }

  @override
  Future<List<RegionalResource>> getRegionalResources() async {
    return _datasource.regionalResources;
  }

  @override
  Future<List<GovtAuditEvent>> getAuditEvents() async {
    return _datasource.auditEvents;
  }

  @override
  Future<void> updateDoctorStatus(String bmdcId, String status) async {
    final index = _datasource.doctors.indexWhere((d) => d.bmdcId == bmdcId);
    if (index != -1) {
      final doc = _datasource.doctors[index];
      _datasource.doctors[index] = doc.copyWith(status: status);

      // Log audit event
      final eventId = 'au-${DateTime.now().millisecondsSinceEpoch}';
      final action = status == 'Suspended' ? 'Practitioner Suspended' : 'Practitioner Reinstated';
      final alertStatus = status == 'Suspended' ? 'danger' : 'success';
      
      _datasource.auditEvents.insert(0, GovtAuditEvent(
        id: eventId,
        action: action,
        target: doc.name,
        description: 'Status of ${doc.name} ($bmdcId) was changed to $status.',
        timestamp: 'Just now',
        operator: 'MoHFW Registry Board',
        status: alertStatus,
      ));

      _datasource.recalculateDashboardStats();
    }
  }

  @override
  Future<void> performHospitalAudit(String facilityId, double newScore, String status, String comment) async {
    final index = _datasource.hospitals.indexWhere((h) => h.facilityId == facilityId);
    if (index != -1) {
      final hospital = _datasource.hospitals[index];
      _datasource.hospitals[index] = hospital.copyWith(
        complianceScore: newScore,
        status: status,
      );

      // Log audit event
      final eventId = 'au-${DateTime.now().millisecondsSinceEpoch}';
      final alertStatus = status == 'Suspended' ? 'danger' : (status == 'Under Review' ? 'warning' : 'success');

      _datasource.auditEvents.insert(0, GovtAuditEvent(
        id: eventId,
        action: 'Facility Audited',
        target: hospital.name,
        description: 'Audited facility. Status: $status, Compliance Grade: $newScore%. Remarks: $comment',
        timestamp: 'Just now',
        operator: 'Dr. Aminul Islam (MoHFW)',
        status: alertStatus,
      ));

      _datasource.recalculateDashboardStats();
    }
  }

  @override
  Future<void> issueOutbreakAlert(String diseaseName, String title, String description, String riskLevel, String division) async {
    // Add to alerts
    final alertId = 'g-${DateTime.now().millisecondsSinceEpoch}';
    final type = riskLevel == 'High' ? 'danger' : (riskLevel == 'Moderate' ? 'warning' : 'info');
    
    final newAlert = NationalAlert(
      id: alertId,
      title: title,
      description: description,
      timeAgo: 'Just now',
      type: type,
      division: division,
    );

    // Update outbreak stat or insert new
    final outbreakIndex = _datasource.dashboardStats.outbreaks.indexWhere(
      (o) => o.diseaseName.toLowerCase() == diseaseName.toLowerCase()
    );

    List<OutbreakStat> updatedOutbreaks = List.from(_datasource.dashboardStats.outbreaks);
    if (outbreakIndex != -1) {
      final existing = updatedOutbreaks[outbreakIndex];
      updatedOutbreaks[outbreakIndex] = existing.copyWith(
        riskLevel: riskLevel,
        trend: 'Rising',
        activeCases: existing.activeCases + 25,
      );
    } else {
      updatedOutbreaks.insert(0, OutbreakStat(
        id: 'o-${DateTime.now().millisecondsSinceEpoch}',
        diseaseName: diseaseName,
        activeCases: 100,
        weeklyNewCases: 100,
        riskLevel: riskLevel,
        trend: 'Rising',
        affectedAreas: division,
      ));
    }

    _datasource.dashboardStats = _datasource.dashboardStats.copyWith(
      alerts: [newAlert, ..._datasource.dashboardStats.alerts],
      outbreaks: updatedOutbreaks,
    );

    // Log audit event
    final eventId = 'au-${DateTime.now().millisecondsSinceEpoch}';
    _datasource.auditEvents.insert(0, GovtAuditEvent(
      id: eventId,
      action: 'Alert Declared',
      target: diseaseName,
      description: 'Declared national health alert for $diseaseName in $division. Risk Level: $riskLevel.',
      timestamp: 'Just now',
      operator: 'MoHFW Disease Intelligence Unit',
      status: 'warning',
    ));

    _datasource.recalculateDashboardStats();
  }
}

final govtMockDatasourceProvider = Provider<GovtMockDatasource>((ref) {
  return GovtMockDatasource();
});

final govtRepositoryProvider = Provider<GovtRepository>((ref) {
  final ds = ref.watch(govtMockDatasourceProvider);
  return GovtRepositoryImpl(ds);
});
