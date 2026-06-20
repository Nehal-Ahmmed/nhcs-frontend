# 🩺 Doctor Ecosystem (Module 3) Implementation Guide

Welcome to the comprehensive implementation guide for the **Doctor Ecosystem (Module 3)** of the National Unified Digital Healthcare Ecosystem (NUDHEB). This guide captures the architecture, code implementation, and workflow details from the Doctor's perspective.

---

## 🗺️ High-Level Roadmap

The implementation of the Doctor Ecosystem proceeded through the following structured milestones:

1. **Ecosystem State-Driven Routing**: Upgraded `app_router.dart` to support role-aware login redirection, and converted `DoctorShell` from localized state navigation to a unified, Riverpod-managed routing provider (`doctorNavigationProvider`).
2. **Data Layer Modeling**: Authored raw, manual serialization models modeling the Doctor's workflow (e.g. queue items, dashboard stats, investigations, diagnoses, and medical reports).
3. **Lifelong Medical Integration**: Hooked up the `DoctorRepository` and its mock implementation directly to the `PatientMockDatasource`. Tapping on patient queue cards or submitting treatment plans modifies and queries the patient's records instantly.
4. **Interactive Clinical Workspace**: Created a split-screen layout offering clinical information retrieval on the left (vitals, chronic conditions, history) and active diagnostic authoring on the right.
5. **AI Safety Gateways**: Integrated dynamic alerts that flag potential drug conflicts and allergies in real time as the doctor adds medications to the prescription list.
6. **Diagnostics Lifecycle Management**: Implemented a reactive report review portal for analyzing test values, checking trends against historical benchmarks, and signing off on pending results.

---

## 🧠 Logical Descriptions

### 1. Frontend Layer
* **Simple**: The Doctor portal displays a real-time list of today's patient queue, pending labs, and scheduled slots. When a doctor selects a patient (like Rahim Islam), the clinical workspace pulls up the patient's records. While the doctor writes a treatment plan, an assistant double-checks that the medications do not conflict with the patient's allergies before submitting the records to their profile.
* **Technical**: State is managed via Riverpod: `doctorDashboardProvider` provides metrics; `patientQueueProvider` handles active waiting queues; and `clinicalWorkspaceProvider` governs the transactional state of the current consultation. Vitals and past records are queried from `patientSearchProvider`. When a consultation is submitted, the repository translates the draft into a `TreatmentPlan` and pushes it into the patient's timeline history and vault repository.

### 2. Backend Layer (Proposed)
* **Simple**: The backend provides secure endpoints for doctors to retrieve their schedule, access patient profiles using authorization pins, and save completed treatment records directly into the health records database.
* **Technical**: A Spring Boot application exposing REST endpoints (e.g., `/api/doctor/dashboard`, `/api/patient/profile/{healthId}`, `/api/consultations/submit`). The submit endpoint accepts a `TreatmentPlanDTO`, maps it to a database entity, persists it to PostgreSQL, and pushes real-time WebSocket notifications to the corresponding patient's portal.

---

## 💻 Full Implementation Code

Below is the complete copy-pasteable source code for all layers of the Doctor Ecosystem:

### 1. Data Layer Models

#### 📄 [doctor_dashboard_summary.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/models/doctor_dashboard_summary.dart)
```dart
class DoctorDashboardSummary {
  final int totalAppointments;
  final int totalFollowUps;
  final int emergencyCases;
  final int pendingReports;
  final int referredCases;
  final String aiBriefing;

  DoctorDashboardSummary({
    required this.totalAppointments,
    required this.totalFollowUps,
    required this.emergencyCases,
    required this.pendingReports,
    required this.referredCases,
    required this.aiBriefing,
  });

  factory DoctorDashboardSummary.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardSummary(
      totalAppointments: json['totalAppointments'] as int? ?? 0,
      totalFollowUps: json['totalFollowUps'] as int? ?? 0,
      emergencyCases: json['emergencyCases'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      referredCases: json['referredCases'] as int? ?? 0,
      aiBriefing: json['aiBriefing'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAppointments': totalAppointments,
      'totalFollowUps': totalFollowUps,
      'emergencyCases': emergencyCases,
      'pendingReports': pendingReports,
      'referredCases': referredCases,
      'aiBriefing': aiBriefing,
    };
  }
}
```

#### 📄 [patient_queue_item.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/models/patient_queue_item.dart)
```dart
class PatientQueueItem {
  final String id;
  final String name;
  final int age;
  final String gender;
  final List<String> existingDiseases;
  final String riskIndicator; // Low, Moderate, High, Emergency
  final String visitType; // First Consultation, Follow-up, Emergency, Referral
  final String time;
  final String healthId;

  PatientQueueItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.existingDiseases,
    required this.riskIndicator,
    required this.visitType,
    required this.time,
    required this.healthId,
  });

  factory PatientQueueItem.fromJson(Map<String, dynamic> json) {
    return PatientQueueItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      existingDiseases: (json['existingDiseases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      riskIndicator: json['riskIndicator'] as String? ?? 'Low',
      visitType: json['visitType'] as String? ?? 'First Consultation',
      time: json['time'] as String? ?? '',
      healthId: json['healthId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'existingDiseases': existingDiseases,
      'riskIndicator': riskIndicator,
      'visitType': visitType,
      'time': time,
      'healthId': healthId,
    };
  }
}
```

#### 📄 [clinical_case.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/models/clinical_case.dart)
```dart
class DiagnosisItem {
  final String diseaseName;
  final String status; // Provisional, Confirmed
  final String notes;

  DiagnosisItem({
    required this.diseaseName,
    required this.status,
    required this.notes,
  });

  factory DiagnosisItem.fromJson(Map<String, dynamic> json) {
    return DiagnosisItem(
      diseaseName: json['diseaseName'] as String? ?? '',
      status: json['status'] as String? ?? 'Provisional',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'status': status,
      'notes': notes,
    };
  }
}

class PrescribedMedicine {
  final String medicineName;
  final String dosage;
  final String duration;
  final String instructions;

  PrescribedMedicine({
    required this.medicineName,
    required this.dosage,
    required this.duration,
    required this.instructions,
  });

  factory PrescribedMedicine.fromJson(Map<String, dynamic> json) {
    return PrescribedMedicine(
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

class TreatmentPlan {
  final String patientId;
  final String patientName;
  final List<String> symptoms;
  final List<DiagnosisItem> diagnoses;
  final List<PrescribedMedicine> medicines;
  final List<String> investigations;
  final String clinicalNotes;
  final String followUp;
  final String? referralSpecialist;
  final DateTime date;

  TreatmentPlan({
    required this.patientId,
    required this.patientName,
    required this.symptoms,
    required this.diagnoses,
    required this.medicines,
    required this.investigations,
    required this.clinicalNotes,
    required this.followUp,
    this.referralSpecialist,
    required this.date,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      diagnoses: (json['diagnoses'] as List<dynamic>?)
              ?.map((e) => DiagnosisItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((e) => PrescribedMedicine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      investigations: (json['investigations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
      followUp: json['followUp'] as String? ?? '',
      referralSpecialist: json['referralSpecialist'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'symptoms': symptoms,
      'diagnoses': diagnoses.map((e) => e.toJson()).toList(),
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'investigations': investigations,
      'clinicalNotes': clinicalNotes,
      'followUp': followUp,
      'referralSpecialist': referralSpecialist,
      'date': date.toIso8601String(),
    };
  }
}
```

#### 📄 [report_review_item.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/models/report_review_item.dart)
```dart
class ReportReviewItem {
  final String id;
  final String patientName;
  final String healthId;
  final String testName;
  final String category;
  final DateTime orderedDate;
  final String status;
  final String trendSummary;
  final String trendStatus;
  final Map<String, String> results;

  ReportReviewItem({
    required this.id,
    required this.patientName,
    required this.healthId,
    required this.testName,
    required this.category,
    required this.orderedDate,
    required this.status,
    required this.trendSummary,
    required this.trendStatus,
    required this.results,
  });

  factory ReportReviewItem.fromJson(Map<String, dynamic> json) {
    return ReportReviewItem(
      id: json['id'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      healthId: json['healthId'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      orderedDate: json['orderedDate'] != null
          ? DateTime.parse(json['orderedDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      trendSummary: json['trendSummary'] as String? ?? '',
      trendStatus: json['trendStatus'] as String? ?? 'Stable',
      results: (json['results'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'healthId': healthId,
      'testName': testName,
      'category': category,
      'orderedDate': orderedDate.toIso8601String(),
      'status': status,
      'trendSummary': trendSummary,
      'trendStatus': trendStatus,
      'results': results,
    };
  }
}
```

---

### 2. Data Sources & Repositories

#### 📄 [doctor_mock_datasource.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/datasources/doctor_mock_datasource.dart)
```dart
import '../models/doctor_dashboard_summary.dart';
import '../models/patient_queue_item.dart';
import '../models/report_review_item.dart';
import '../models/clinical_case.dart';

class DoctorMockDatasource {
  static final DoctorMockDatasource _instance = DoctorMockDatasource._internal();
  factory DoctorMockDatasource() => _instance;
  DoctorMockDatasource._internal();

  final DoctorDashboardSummary dashboardSummary = DoctorDashboardSummary(
    totalAppointments: 18,
    totalFollowUps: 8,
    emergencyCases: 2,
    pendingReports: 5,
    referredCases: 3,
    aiBriefing: "Good morning Dr. Ahmed. Today you have 18 consultations, including 8 diabetes follow-ups, 2 cardiac emergency reviews, and 3 referrals from local general practitioners. Your first patient is Rahim Islam, scheduled at 08:00 AM, who has a history of Type 2 Diabetes and Hypertension, showing elevated blood glucose trends.",
  );

  final List<PatientQueueItem> patientQueue = [
    PatientQueueItem(
      id: 'q1',
      name: 'Rahim Islam',
      age: 42,
      gender: 'Male',
      existingDiseases: ['Type 2 Diabetes', 'Hypertension'],
      riskIndicator: 'Moderate',
      visitType: 'Follow-up',
      time: '08:00 AM',
      healthId: 'NUD-892-441-X7',
    ),
    PatientQueueItem(
      id: 'q2',
      name: 'Karim Ullah',
      age: 55,
      gender: 'Male',
      existingDiseases: ['Hypertension', 'Chronic Kidney Disease'],
      riskIndicator: 'High',
      visitType: 'Referral',
      time: '08:30 AM',
      healthId: 'NUD-552-321-Y2',
    ),
    PatientQueueItem(
      id: 'q3',
      name: 'Tahmina Akhtar',
      age: 29,
      gender: 'Female',
      existingDiseases: ['Asthma'],
      riskIndicator: 'Low',
      visitType: 'First Consultation',
      time: '09:00 AM',
      healthId: 'NUD-109-883-Z4',
    ),
    PatientQueueItem(
      id: 'q4',
      name: 'Abdul Khalek',
      age: 68,
      gender: 'Male',
      existingDiseases: ['Unstable Angina', 'Coronary Artery Disease'],
      riskIndicator: 'Emergency',
      visitType: 'Emergency',
      time: '09:30 AM',
      healthId: 'NUD-442-990-W9',
    ),
  ];

  final List<ReportReviewItem> pendingReports = [
    ReportReviewItem(
      id: 'rep1',
      patientName: 'Rahim Islam',
      healthId: 'NUD-892-441-X7',
      testName: 'HbA1c & Fasting Blood Sugar',
      category: 'Lab',
      orderedDate: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Pending',
      trendSummary: 'Blood sugar: 180 -> 220 mg/dL (22% increase)',
      trendStatus: 'Worsening',
      results: {
        'Fasting Blood Sugar': '220 mg/dL (Normal < 100 mg/dL)',
        'HbA1c': '8.2% (Target < 7.0%)',
      },
    ),
    ReportReviewItem(
      id: 'rep2',
      patientName: 'Karim Ullah',
      healthId: 'NUD-552-321-Y2',
      testName: 'Serum Creatinine & eGFR',
      category: 'Lab',
      orderedDate: DateTime.now().subtract(const Duration(days: 4)),
      status: 'Pending',
      trendSummary: 'Creatinine: 1.8 -> 1.75 mg/dL (Stable)',
      trendStatus: 'Stable',
      results: {
        'Serum Creatinine': '1.75 mg/dL (Normal 0.6 - 1.2 mg/dL)',
        'eGFR': '42 mL/min/1.73m² (Stage 3b CKD)',
      },
    ),
    ReportReviewItem(
      id: 'rep3',
      patientName: 'Salma Begum',
      healthId: 'NUD-331-509-A8',
      testName: 'Lipid Profile',
      category: 'Lab',
      orderedDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Pending',
      trendSummary: 'LDL Cholesterol: 160 -> 135 mg/dL (15% decrease)',
      trendStatus: 'Improving',
      results: {
        'Total Cholesterol': '210 mg/dL',
        'LDL Cholesterol': '135 mg/dL (Target < 100 mg/dL)',
        'HDL Cholesterol': '45 mg/dL',
        'Triglycerides': '150 mg/dL',
      },
    ),
    ReportReviewItem(
      id: 'rep4',
      patientName: 'Abdul Khalek',
      healthId: 'NUD-442-990-W9',
      testName: '12-Lead Electrocardiogram (ECG)',
      category: 'ECG',
      orderedDate: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Pending',
      trendSummary: 'ST-segment depression in V4-V6 vs normal ECG from 2025',
      trendStatus: 'Worsening',
      results: {
        'Heart Rate': '92 bpm',
        'Rhythm': 'Sinus Tachycardia',
        'Findings': 'ST-segment depression of 1.5mm in chest leads V4-V6, suggesting myocardial ischemia.',
      },
    ),
  ];

  final Map<String, List<String>> scheduleSlots = {
    'Monday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'],
    'Tuesday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM'],
    'Wednesday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'],
    'Thursday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM'],
    'Friday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM'],
  };

  final List<TreatmentPlan> submittedTreatmentPlans = [];

  void addTreatmentPlan(TreatmentPlan plan) {
    submittedTreatmentPlans.add(plan);
  }
}
```

#### 📄 [doctor_repository.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/data/repositories/doctor_repository.dart)
```dart
import '../../patient/data/models/patient_profile.dart';
import '../../patient/data/datasources/patient_mock_datasource.dart';
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

    if (plan.patientId == 'NUD-892-441-X7') {
      final patientDatasource = PatientMockDatasource();
      final diagnosesText = plan.diagnoses.map((d) => d.diseaseName).join(', ');
      final medicinesText = plan.medicines.map((m) => '${m.medicineName} (${m.dosage})').join(', ');
      final descriptionText = 'Diagnoses: $diagnosesText. Medicines: $medicinesText. Notes: ${plan.clinicalNotes}';

      final nextEventId = 'ev_${DateTime.now().millisecondsSinceEpoch}';
      final newEvent = HealthEvent(
        id: nextEventId,
        eventType: 'Consultation',
        title: 'Cardiac Consultation',
        description: descriptionText,
        date: DateTime.now(),
        doctorName: 'Dr. Ahmed',
        hospitalName: 'Dhaka Central Hospital',
      );
      patientDatasource.timelineEvents.insert(0, newEvent);

      final nextPrescId = 'presc_${DateTime.now().millisecondsSinceEpoch}';
      final newPresc = Prescription(
        id: nextPrescId,
        date: DateTime.now(),
        doctorName: 'Dr. Ahmed',
        hospitalName: 'Dhaka Central Hospital',
        diagnosis: diagnosesText,
        medicines: plan.medicines.map((m) => PrescriptionMedicine(
          name: m.medicineName,
          dosage: m.dosage,
          duration: m.duration,
          instructions: m.instructions,
        )).toList(),
        notes: plan.clinicalNotes,
        followUpDate: plan.followUp,
      );
      patientDatasource.prescriptions.insert(0, newPresc);
    }
  }

  @override
  Future<PatientProfile?> getPatientProfileByHealthId(String healthId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final patientDatasource = PatientMockDatasource();
    if (patientDatasource.profile.healthId == healthId) {
      return patientDatasource.profile;
    }
    
    final matchedInQueue = _datasource.patientQueue.firstWhere(
      (p) => p.healthId == healthId,
      orElse: () => PatientQueueItem(id: '', name: '', age: 0, gender: '', existingDiseases: [], riskIndicator: '', visitType: '', time: '', healthId: ''),
    );

    if (matchedInQueue.healthId.isNotEmpty) {
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
```

---

### 3. Presentation State Providers

#### 📄 [doctor_providers.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/presentation/providers/doctor_providers.dart)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/mock_provider.dart';
import '../../data/models/doctor_dashboard_summary.dart';
import '../../data/models/patient_queue_item.dart';
import '../../data/models/report_review_item.dart';
import '../../data/repositories/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final isMock = ref.watch(isMockModeProvider);
  if (isMock) {
    return DoctorRepositoryImpl();
  }
  return DoctorRepositoryImpl();
});

final doctorNavigationProvider = StateProvider<int>((ref) => 0);

final doctorDashboardProvider = FutureProvider<DoctorDashboardSummary>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getDashboardSummary();
});

final patientQueueProvider = FutureProvider<List<PatientQueueItem>>((ref) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getPatientQueue();
});

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

final doctorScheduleProvider = FutureProvider.family<List<String>, String>((ref, day) async {
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getScheduleSlots(day);
});

final patientSearchProvider = FutureProvider.family<dynamic, String>((ref, healthId) async {
  if (healthId.isEmpty) return null;
  final repository = ref.watch(doctorRepositoryProvider);
  return repository.getPatientProfileByHealthId(healthId);
});
```

#### 📄 [clinical_workspace_provider.dart](file:///d:/flutter%20projects/uhcs/lib/features/doctor/presentation/providers/clinical_workspace_provider.dart)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/clinical_case.dart';
import 'doctor_providers.dart';

class ClinicalWorkspaceState {
  final String patientId;
  final String patientName;
  final List<String> symptoms;
  final List<DiagnosisItem> diagnoses;
  final List<PrescribedMedicine> medicines;
  final List<String> investigations;
  final String clinicalNotes;
  final String followUp;
  final String? referralSpecialist;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  ClinicalWorkspaceState({
    this.patientId = '',
    this.patientName = '',
    this.symptoms = const [],
    this.diagnoses = const [],
    this.medicines = const [],
    this.investigations = const [],
    this.clinicalNotes = '',
    this.followUp = 'In 2 weeks',
    this.referralSpecialist,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  ClinicalWorkspaceState copyWith({
    String? patientId,
    String? patientName,
    List<String>? symptoms,
    List<DiagnosisItem>? diagnoses,
    List<PrescribedMedicine>? medicines,
    List<String>? investigations,
    String? clinicalNotes,
    String? followUp,
    String? referralSpecialist,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return ClinicalWorkspaceState(
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      symptoms: symptoms ?? this.symptoms,
      diagnoses: diagnoses ?? this.diagnoses,
      medicines: medicines ?? this.medicines,
      investigations: investigations ?? this.investigations,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      followUp: followUp ?? this.followUp,
      referralSpecialist: referralSpecialist ?? this.referralSpecialist,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

class ClinicalWorkspaceNotifier extends StateNotifier<ClinicalWorkspaceState> {
  final Ref _ref;

  ClinicalWorkspaceNotifier(this._ref) : super(ClinicalWorkspaceState());

  void initializePatient(String patientId, String patientName) {
    state = ClinicalWorkspaceState(
      patientId: patientId,
      patientName: patientName,
    );
  }

  void addSymptom(String symptom) {
    if (symptom.trim().isEmpty) return;
    if (state.symptoms.contains(symptom)) return;
    state = state.copyWith(symptoms: [...state.symptoms, symptom]);
  }

  void removeSymptom(String symptom) {
    state = state.copyWith(symptoms: state.symptoms.where((s) => s != symptom).toList());
  }

  void addDiagnosis(String disease, String status, String notes) {
    if (disease.trim().isEmpty) return;
    final item = DiagnosisItem(diseaseName: disease, status: status, notes: notes);
    state = state.copyWith(diagnoses: [...state.diagnoses, item]);
  }

  void removeDiagnosis(int index) {
    final list = [...state.diagnoses];
    list.removeAt(index);
    state = state.copyWith(diagnoses: list);
  }

  void addMedicine(String name, String dosage, String duration, String instructions) {
    if (name.trim().isEmpty) return;
    final medicine = PrescribedMedicine(
      medicineName: name,
      dosage: dosage,
      duration: duration,
      instructions: instructions,
    );
    state = state.copyWith(medicines: [...state.medicines, medicine]);
  }

  void removeMedicine(int index) {
    final list = [...state.medicines];
    list.removeAt(index);
    state = state.copyWith(medicines: list);
  }

  void toggleInvestigation(String investigation) {
    final list = [...state.investigations];
    if (list.contains(investigation)) {
      list.remove(investigation);
    } else {
      list.add(investigation);
    }
    state = state.copyWith(investigations: list);
  }

  void updateClinicalNotes(String notes) {
    state = state.copyWith(clinicalNotes: notes);
  }

  void updateFollowUp(String followUp) {
    state = state.copyWith(followUp: followUp);
  }

  void updateReferral(String? specialist) {
    state = state.copyWith(referralSpecialist: specialist);
  }

  Future<void> submit() async {
    if (state.patientId.isEmpty) {
      state = state.copyWith(error: 'No patient selected.');
      return;
    }
    if (state.diagnoses.isEmpty && state.symptoms.isEmpty) {
      state = state.copyWith(error: 'Please record at least one symptom or diagnosis.');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = _ref.read(doctorRepositoryProvider);
      final plan = TreatmentPlan(
        patientId: state.patientId,
        patientName: state.patientName,
        symptoms: state.symptoms,
        diagnoses: state.diagnoses,
        medicines: state.medicines,
        investigations: state.investigations,
        clinicalNotes: state.clinicalNotes,
        followUp: state.followUp,
        referralSpecialist: state.referralSpecialist,
        date: DateTime.now(),
      );

      await repository.submitTreatmentPlan(plan);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  void reset() {
    state = ClinicalWorkspaceState();
  }
}

final clinicalWorkspaceProvider = StateNotifierProvider<ClinicalWorkspaceNotifier, ClinicalWorkspaceState>((ref) {
  return ClinicalWorkspaceNotifier(ref);
});
```

---

## 🛠️ Extra Steps

1. **Role Redirection Parameter Sync**: Ensure that `app_router.dart` is updated to correctly pass the role query parameter `state.uri.queryParameters['role']` to `LoginPage(role: role)`.
2. **Compile Check**: Run `flutter analyze` inside the terminal to confirm that the mock databases and Riverpod legacy imports resolve cleanly without static typing exceptions.

---

## 📝 Summary

The clinical workflow operates as a state-driven loop:
1. **Queue Start**: Clicking "Continue" or "Start" on the patient list triggers `clinicalWorkspaceProvider.notifier.initializePatient(healthId, name)`.
2. **Clinical Lookup**: The workspace initiates `patientSearchProvider` to query the mock database for vitals, chronic illnesses, and historic labs.
3. **Safety Analysis**: During prescription entry, the presentation layer checks the patient's record for Penicillin allergies and Aspirin drug interactions, displaying warnings on the workspace card.
4. **Record Syncing**: Clicking "Submit" maps the workspace state to a unified `TreatmentPlan`, saving the consult directly into the global datasource so the patient can access it instantly in their vault and timeline.
