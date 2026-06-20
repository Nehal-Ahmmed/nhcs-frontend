import '../../../patient/data/models/patient_profile.dart';
import '../../../patient/data/models/health_event.dart';
import '../../../patient/data/models/medical_record.dart';
import '../../../patient/data/datasources/patient_mock_datasource.dart';
import '../datasources/doctor_mock_datasource.dart';
import '../models/doctor_dashboard_summary.dart';
import '../models/patient_queue_item.dart';
import '../models/report_review_item.dart';
import '../models/clinical_case.dart';

abstract class DoctorRepository {
  Future<DoctorDashboardSummary> getDashboardSummary();
  Future<List<PatientQueueItem>> getPatientQueue();
  Future<List<ReportReviewItem>> getPendingReports();
  Future<List<String>> getScheduleSlots(String day);
  Future<void> submitTreatmentPlan(TreatmentPlan plan);
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId);
  Future<void> reviewReport(String reportId);
}

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorMockDatasource _datasource = DoctorMockDatasource();

  @override
  Future<DoctorDashboardSummary> getDashboardSummary() async {
    // Simulate slight network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return _datasource.dashboardSummary;
  }

  @override
  Future<List<PatientQueueItem>> getPatientQueue() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _datasource.patientQueue;
  }

  @override
  Future<List<ReportReviewItem>> getPendingReports() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _datasource.pendingReports;
  }

  @override
  Future<List<String>> getScheduleSlots(String day) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _datasource.scheduleSlots[day] ?? [];
  }

  @override
  Future<void> submitTreatmentPlan(TreatmentPlan plan) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _datasource.addTreatmentPlan(plan);

    // If it is for Rahim, also add it to Rahim's patient history timeline!
    if (plan.patientId == 'NUD-892-441-X7') {
      final patientDatasource = PatientMockDatasource();
      
      // Convert treatment plan diagnoses/investigations to description text
      final diagnosesText = plan.diagnoses.map((d) => d.diseaseName).join(', ');
      final medicinesText = plan.medicines.map((m) => '${m.medicineName} (${m.dosage})').join(', ');
      final descriptionText = 'Diagnoses: $diagnosesText. Medicines: $medicinesText. Notes: ${plan.clinicalNotes}';

      // Create a HealthEvent for Rahim's timeline
      final nextEventId = 'ev_${DateTime.now().millisecondsSinceEpoch}';
      final newEvent = HealthEvent(
        id: nextEventId,
        type: HealthEventType.consultation,
        title: 'Cardiac Consultation',
        description: descriptionText,
        date: DateTime.now(),
        doctorName: 'Dr. Ahmed',
        hospitalName: 'Dhaka Central Hospital',
      );
      
      patientDatasource.healthEvents.insert(0, newEvent);

      // Add prescription to Rahim's vault
      final nextPrescId = 'presc_${DateTime.now().millisecondsSinceEpoch}';
      final newPresc = Prescription(
        id: nextPrescId,
        date: DateTime.now(),
        doctorName: 'Dr. Ahmed',
        doctorSpecialization: 'Cardiology',
        hospitalName: 'Dhaka Central Hospital',
        diagnosis: diagnosesText,
        medicines: plan.medicines.map((m) => Medicine(
          name: m.medicineName,
          dosage: m.dosage,
          duration: m.duration,
          instruction: m.instructions,
        )).toList(),
        clinicalNotes: plan.clinicalNotes,
        followUpDate: plan.followUp,
      );
      patientDatasource.prescriptions.insert(0, newPresc);
    }
  }

  @override
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if it is Rahim Islam
    final patientDatasource = PatientMockDatasource();
    if (patientDatasource.profile.healthId == healthId) {
      return patientDatasource.profile;
    }
    
    // If not Rahim, check our patient queue to simulate general profile matching
    final matchedInQueue = _datasource.patientQueue.firstWhere(
      (p) => p.healthId == healthId,
      orElse: () => PatientQueueItem(id: '', name: '', age: 0, gender: '', existingDiseases: [], riskIndicator: '', visitType: '', time: '', healthId: ''),
    );

    if (matchedInQueue.healthId.isNotEmpty) {
      // Return a basic profile for other queue patients
      return PatientProfile(
        healthId: matchedInQueue.healthId,
        name: matchedInQueue.name,
        dateOfBirth: DateTime.now().subtract(Duration(days: matchedInQueue.age * 365)),
        gender: matchedInQueue.gender,
        bloodGroup: 'B+',
        nationalId: '1234567890',
        phone: '+880 1555-555555',
        occupation: 'Service',
        maritalStatus: 'Married',
        presentAddress: 'Dhaka, Bangladesh',
        permanentAddress: 'Dhaka, Bangladesh',
        emergencyContacts: [],
        allergies: [],
        chronicDiseases: matchedInQueue.existingDiseases.map((d) => ChronicDisease(
          diseaseName: d,
          status: 'Active',
          diagnosedDate: DateTime.now().subtract(const Duration(days: 365)),
        )).toList(),
        vitals: VitalSign(
          bpSystolic: '120',
          bpDiastolic: '80',
          bloodGlucose: '110',
          heartRate: '72',
          weight: '70',
          lastUpdated: DateTime.now(),
        ),
      );
    }

    return null;
  }

  @override
  Future<void> reviewReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _datasource.pendingReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      // Mark as reviewed
      final item = _datasource.pendingReports[index];
      _datasource.pendingReports[index] = ReportReviewItem(
        id: item.id,
        patientName: item.patientName,
        healthId: item.healthId,
        testName: item.testName,
        category: item.category,
        orderedDate: item.orderedDate,
        status: 'Reviewed',
        trendSummary: item.trendSummary,
        trendStatus: item.trendStatus,
        results: item.results,
      );
    }
  }
}
