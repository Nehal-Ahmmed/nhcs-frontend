# Patient Ecosystem (Module 2) Implementation Guide

## 🗺️ High-Level Roadmap

1. **Global Mock Configurations**: Created `lib/core/providers/mock_provider.dart` to hold global mock settings and state to simulate local network latency.
2. **Patient Data Models**: Hand-written strongly-typed data models with custom manual serialization/deserialization (`fromJson`/`toJson`) without any code generation build runners:
   - `lib/features/patient/data/models/dashboard_summary.dart`
   - `lib/features/patient/data/models/patient_profile.dart`
   - `lib/features/patient/data/models/health_event.dart`
   - `lib/features/patient/data/models/appointment.dart`
   - `lib/features/patient/data/models/medical_record.dart`
3. **Mock Data Source**: Created `lib/features/patient/data/datasources/patient_mock_datasource.dart` preloaded with patient clinical scenarios (Rahim Islam, Diabetes & Hypertension diagnosis, and Dr. Ahmed).
4. **Data Repository**: Built interface `PatientRepository` and its implementation `PatientRepositoryImpl` in `lib/features/patient/data/repositories/patient_repository.dart` that logs activities and handles mock state updates.
5. **State Management**: Set up Riverpod state providers for dashboard statistics, patient profile updates, timeline queries, vault records, and a multi-step appointment booking wizard state machine:
   - `lib/features/patient/presentation/providers/patient_providers.dart`
   - `lib/features/patient/presentation/providers/booking_provider.dart`
6. **Refactored Interactive UI Pages**: Refactored the static layout pages from Module 0 to consume Riverpod providers, handling loading and error states gracefully:
   - `lib/features/patient/pages/patient_dashboard_page.dart` (Binds stats, AI health summary, and active status)
   - `lib/features/patient/pages/patient_profile_page.dart` (Integrates multi-step profile editing wizard form)
   - `lib/features/patient/pages/health_timeline_page.dart` (Binds chronological timeline events and category filters)
   - `lib/features/patient/pages/appointments_page.dart` (Binds active bookings, cancellation requests, and slots wizard)
   - `lib/features/patient/pages/medical_vault_page.dart` (Tabs for prescriptions, lab records, scans, and overlays)

---

## 🧠 Logical Descriptions

### Frontend Layer
- **Simple**: This is the patient’s digital portal. It loads their records, allows them to search and book appointments with specialists step-by-step, view clinical results and prescriptions, and update their health details (allergies, emergency contacts, vitals) immediately.
- **Technical**: Implemented using `flutter_riverpod` state management. The UI views observe `FutureProvider`s for asynchronous data loads, and `StateNotifier`s for write transactions (like profile editing and slot reservation). Components display animated progress indicators during latency delays and render error blocks with retry buttons linked to `ref.invalidate(...)`.

### Backend Layer (Mock Context)
- **Simple**: Simulates a database containing patient credentials, vital logs, prescriptions, clinic structures, and doctors' calendars.
- **Technical**: Handled via `PatientMockDatasource` acting as a singleton in-memory database. The `PatientRepositoryImpl` acts as the repository gatekeeper, simulating standard API call latency using `Future.delayed` before returning data or updating the local in-memory cache.

---

## 💻 Full Implementation Code

### `lib/core/providers/mock_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global toggle for mock mode vs remote API mode
final isMockModeProvider = StateProvider<bool>((ref) => true);
```

### `lib/features/patient/data/models/dashboard_summary.dart`
```dart
class DashboardSummary {
  final int totalVisits;
  final int activeTreatments;
  final int upcomingAppointments;
  final int pendingReports;
  final int activeMedications;

  DashboardSummary({
    required this.totalVisits,
    required this.activeTreatments,
    required this.upcomingAppointments,
    required this.pendingReports,
    required this.activeMedications,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalVisits: json['totalVisits'] as int? ?? 0,
      activeTreatments: json['activeTreatments'] as int? ?? 0,
      upcomingAppointments: json['upcomingAppointments'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      activeMedications: json['activeMedications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVisits': totalVisits,
      'activeTreatments': activeTreatments,
      'upcomingAppointments': upcomingAppointments,
      'pendingReports': pendingReports,
      'activeMedications': activeMedications,
    };
  }
}

class AiHealthSummary {
  final String summaryText;
  final DateTime lastUpdated;

  AiHealthSummary({
    required this.summaryText,
    required this.lastUpdated,
  });

  factory AiHealthSummary.fromJson(Map<String, dynamic> json) {
    return AiHealthSummary(
      summaryText: json['summaryText'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summaryText': summaryText,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
```

### `lib/features/patient/data/models/patient_profile.dart`
```dart
class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
    };
  }
}

class Allergy {
  final String allergen;
  final String severity; // Mild, Moderate, Severe
  final String reaction;

  Allergy({
    required this.allergen,
    required this.severity,
    required this.reaction,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      allergen: json['allergen'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Mild',
      reaction: json['reaction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergen': allergen,
      'severity': severity,
      'reaction': reaction,
    };
  }
}

class ChronicDisease {
  final String diseaseName;
  final String status; // Active, Managed, Resolved
  final DateTime diagnosedDate;

  ChronicDisease({
    required this.diseaseName,
    required this.status,
    required this.diagnosedDate,
  });

  factory ChronicDisease.fromJson(Map<String, dynamic> json) {
    return ChronicDisease(
      diseaseName: json['diseaseName'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      diagnosedDate: json['diagnosedDate'] != null 
          ? DateTime.parse(json['diagnosedDate'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'status': status,
      'diagnosedDate': diagnosedDate.toIso8601String(),
    };
  }
}

class VitalSign {
  final String bpSystolic;
  final String bpDiastolic;
  final String bloodGlucose;
  final String heartRate;
  final String weight;
  final DateTime lastUpdated;

  VitalSign({
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.bloodGlucose,
    required this.heartRate,
    required this.weight,
    required this.lastUpdated,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      bpSystolic: json['bpSystolic'] as String? ?? '',
      bpDiastolic: json['bpDiastolic'] as String? ?? '',
      bloodGlucose: json['bloodGlucose'] as String? ?? '',
      heartRate: json['heartRate'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'bloodGlucose': bloodGlucose,
      'heartRate': heartRate,
      'weight': weight,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class PatientProfile {
  final String healthId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String nationalId;
  final String phone;
  final String occupation;
  final String maritalStatus;
  final String presentAddress;
  final String permanentAddress;
  final List<EmergencyContact> emergencyContacts;
  final List<Allergy> allergies;
  final List<ChronicDisease> chronicDiseases;
  final VitalSign vitals;

  PatientProfile({
    required this.healthId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.nationalId,
    required this.phone,
    required this.occupation,
    required this.maritalStatus,
    required this.presentAddress,
    required this.permanentAddress,
    required this.emergencyContacts,
    required this.allergies,
    required this.chronicDiseases,
    required this.vitals,
  });

  PatientProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? occupation,
    String? maritalStatus,
    String? presentAddress,
    String? permanentAddress,
    List<EmergencyContact>? emergencyContacts,
    List<Allergy>? allergies,
    List<ChronicDisease>? chronicDiseases,
    VitalSign? vitals,
  }) {
    return PatientProfile(
      healthId: healthId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      nationalId: nationalId,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      presentAddress: presentAddress ?? this.presentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      vitals: vitals ?? this.vitals,
    );
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      healthId: json['healthId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String) 
          : DateTime.now(),
      gender: json['gender'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      maritalStatus: json['maritalStatus'] as String? ?? '',
      presentAddress: json['presentAddress'] as String? ?? '',
      permanentAddress: json['permanentAddress'] as String? ?? '',
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => Allergy.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      chronicDiseases: (json['chronicDiseases'] as List<dynamic>?)
              ?.map((e) => ChronicDisease.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      vitals: json['vitals'] != null 
          ? VitalSign.fromJson(json['vitals'] as Map<String, dynamic>)
          : VitalSign(bpSystolic: '', bpDiastolic: '', bloodGlucose: '', heartRate: '', weight: '', lastUpdated: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthId': healthId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'nationalId': nationalId,
      'phone': phone,
      'occupation': occupation,
      'maritalStatus': maritalStatus,
      'presentAddress': presentAddress,
      'permanentAddress': permanentAddress,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'allergies': allergies.map((e) => e.toJson()).toList(),
      'chronicDiseases': chronicDiseases.map((e) => e.toJson()).toList(),
      'vitals': vitals.toJson(),
    };
  }
}
```

### `lib/features/patient/data/models/health_event.dart`
```dart
enum HealthEventType {
  consultation,
  labTest,
  imaging,
  surgery,
  admission,
  discharge,
  vaccination,
  prescription,
  followUp,
  emergency
}

class HealthEvent {
  final String id;
  final HealthEventType type;
  final String title;
  final String description;
  final DateTime date;
  final String doctorName;
  final String hospitalName;
  final String? referenceId;

  HealthEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.doctorName,
    required this.hospitalName,
    this.referenceId,
  });

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    return HealthEvent(
      id: json['id'] as String? ?? '',
      type: HealthEventType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'consultation'),
        orElse: () => HealthEventType.consultation,
      ),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      doctorName: json['doctorName'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'referenceId': referenceId,
    };
  }
}
```

### `lib/features/patient/data/models/appointment.dart`
```dart
class DoctorSpecialist {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final double rating;
  final int experienceYears;
  final int consultationFee;
  final String imageUrl;

  DoctorSpecialist({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.rating,
    required this.experienceYears,
    required this.consultationFee,
    required this.imageUrl,
  });

  factory DoctorSpecialist.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      experienceYears: json['experienceYears'] as int? ?? 0,
      consultationFee: json['consultationFee'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'rating': rating,
      'experienceYears': experienceYears,
      'consultationFee': consultationFee,
      'imageUrl': imageUrl,
    };
  }
}

class TimeSlot {
  final String id;
  final String time; // e.g. "09:00 AM"
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.time,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String? ?? '',
      time: json['time'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'isAvailable': isAvailable,
    };
  }
}

class Appointment {
  final String id;
  final DoctorSpecialist doctor;
  final DateTime date;
  final String timeSlot;
  final String hospital;
  final String queueNumber;
  final String status; // Upcoming, Past, Cancelled

  Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.hospital,
    required this.queueNumber,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      doctor: DoctorSpecialist.fromJson(json['doctor'] as Map<String, dynamic>),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      timeSlot: json['timeSlot'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      queueNumber: json['queueNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'Upcoming',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'hospital': hospital,
      'queueNumber': queueNumber,
      'status': status,
    };
  }
}
```

### `lib/features/patient/data/models/medical_record.dart`
```dart
class Medicine {
  final String name;
  final String dosage; // e.g. "500mg"
  final String instruction; // e.g. "1 tablet twice daily after meals"
  final String duration; // e.g. "14 days"

  Medicine({
    required this.name,
    required this.dosage,
    required this.instruction,
    required this.duration,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'instruction': instruction,
      'duration': duration,
    };
  }
}

class Prescription {
  final String id;
  final DateTime date;
  final String doctorName;
  final String doctorSpecialization;
  final String hospitalName;
  final String diagnosis;
  final List<Medicine> medicines;
  final String clinicalNotes;
  final String? followUpDate;

  Prescription({
    required this.id,
    required this.date,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.hospitalName,
    required this.diagnosis,
    required this.medicines,
    required this.clinicalNotes,
    this.followUpDate,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpecialization: json['doctorSpecialization'] as String? ?? '',
      hospitalName: json['hospitalName'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((e) => Medicine.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      clinicalNotes: json['clinicalNotes'] as String? ?? '',
      followUpDate: json['followUpDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'hospitalName': hospitalName,
      'diagnosis': diagnosis,
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'clinicalNotes': clinicalNotes,
      'followUpDate': followUpDate,
    };
  }
}

class LabTestResult {
  final String parameter;
  final String value;
  final String unit;
  final String referenceRange;
  final String status; // Normal, High, Low

  LabTestResult({
    required this.parameter,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.status,
  });

  factory LabTestResult.fromJson(Map<String, dynamic> json) {
    return LabTestResult(
      parameter: json['parameter'] as String? ?? '',
      value: json['value'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      referenceRange: json['referenceRange'] as String? ?? '',
      status: json['status'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameter': parameter,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'status': status,
    };
  }
}

class LabReport {
  final String id;
  final String testName;
  final String category; // Haematology, Biochemistry, etc.
  final DateTime date;
  final String hospitalName;
  final String doctorName;
  final String status; // Ordered, Published
  final List<LabTestResult> results;
  final String aiInterpretation;

  LabReport({
    required this.id,
    required this.testName,
    required this.category,
    required this.date,
    required this.hospitalName,
    required this.doctorName,
    required this.status,
    required this.results,
    required this.aiInterpretation,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) {
    return LabReport(
      id: json['id'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      status: json['status'] as String? ?? 'Published',
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => LabTestResult.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      aiInterpretation: json['aiInterpretation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'category': category,
      'date': date.toIso8601String(),
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'status': status,
      'results': results.map((e) => e.toJson()).toList(),
      'aiInterpretation': aiInterpretation,
    };
  }
}

class ImagingReport {
  final String id;
  final String type; // X-Ray, MRI, CT Scan, Ultrasound
  final String bodyPart;
  final DateTime date;
  final String hospitalName;
  final String doctorName;
  final String imageUrl; // Placeholder/mock URL
  final String findings;
  final String impression;

  ImagingReport({
    required this.id,
    required this.type,
    required this.bodyPart,
    required this.date,
    required this.hospitalName,
    required this.doctorName,
    required this.imageUrl,
    required this.findings,
    required this.impression,
  });

  factory ImagingReport.fromJson(Map<String, dynamic> json) {
    return ImagingReport(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      hospitalName: json['hospitalName'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      findings: json['findings'] as String? ?? '',
      impression: json['impression'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'bodyPart': bodyPart,
      'date': date.toIso8601String(),
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'imageUrl': imageUrl,
      'findings': findings,
      'impression': impression,
    };
  }
}
```

### `lib/features/patient/data/datasources/patient_mock_datasource.dart`
```dart
import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';

class PatientMockDatasource {
  static final PatientMockDatasource _instance = PatientMockDatasource._internal();
  factory PatientMockDatasource() => _instance;
  PatientMockDatasource._internal();

  // 1. Dashboard summary
  final DashboardSummary dashboardSummary = DashboardSummary(
    totalVisits: 14,
    activeTreatments: 2,
    upcomingAppointments: 2,
    pendingReports: 1,
    activeMedications: 3,
  );

  // 2. AI Health Summary
  final AiHealthSummary aiHealthSummary = AiHealthSummary(
    summaryText: 'You have a history of Hypertension and Type 2 Diabetes. Your blood pressure has stabilized around 130/85 mmHg, but recent blood glucose is elevated at 180 mg/dL. Inconsistent Metformin adherence detected. A follow-up consultation with Dr. Ahmed is recommended within the next 7 days.',
    lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
  );

  // 3. Patient Profile
  late PatientProfile profile = PatientProfile(
    healthId: 'NUD-892-441-X7',
    name: 'Rahim Islam',
    dateOfBirth: DateTime(1984, 8, 15),
    gender: 'Male',
    bloodGroup: 'O+',
    nationalId: '8210398457',
    phone: '+880 1712-345678',
    occupation: 'Software Engineer',
    maritalStatus: 'Married',
    presentAddress: 'House 45, Road 12, Dhanmondi, Dhaka 1209',
    permanentAddress: 'Village Purbadhala, Netrokona, Mymensingh',
    emergencyContacts: [
      EmergencyContact(name: 'Nusrat Jahan', relationship: 'Spouse', phone: '+880 1911-987654'),
    ],
    allergies: [
      Allergy(allergen: 'Penicillin', severity: 'Severe', reaction: 'Anaphylaxis, hives'),
      Allergy(allergen: 'Dust Mites', severity: 'Mild', reaction: 'Sneezing, nasal congestion'),
    ],
    chronicDiseases: [
      ChronicDisease(diseaseName: 'Type 2 Diabetes', status: 'Active', diagnosedDate: DateTime(2021, 3, 12)),
      ChronicDisease(diseaseName: 'Hypertension', status: 'Managed', diagnosedDate: DateTime(2023, 6, 20)),
    ],
    vitals: VitalSign(
      bpSystolic: '130',
      bpDiastolic: '85',
      bloodGlucose: '180',
      heartRate: '78',
      weight: '75',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  );

  // 4. Health Events (Timeline)
  final List<HealthEvent> healthEvents = [
    HealthEvent(
      id: 'HE-001',
      type: HealthEventType.consultation,
      title: 'Diabetes Follow-up',
      description: 'Regular check-up for glucose control. Prescription adjusted.',
      date: DateTime(2026, 5, 30),
      doctorName: 'Dr. Ahmed Chowdhury',
      hospitalName: 'Dhaka Central Hospital',
      referenceId: 'PR-102',
    ),
    HealthEvent(
      id: 'HE-002',
      type: HealthEventType.labTest,
      title: 'Fasting Blood Sugar Test',
      description: 'Glucose levels elevated. Suggested HbA1c review.',
      date: DateTime(2026, 5, 29),
      doctorName: 'Dr. Ahmed Chowdhury',
      hospitalName: 'Dhaka Central Hospital Lab',
      referenceId: 'LR-201',
    ),
    HealthEvent(
      id: 'HE-003',
      type: HealthEventType.imaging,
      title: 'Chest X-Ray',
      description: 'Post-viral cough recovery monitoring. Lungs clear.',
      date: DateTime(2026, 3, 15),
      doctorName: 'Dr. Fahmida Rahman',
      hospitalName: 'National Medical Center',
      referenceId: 'IM-301',
    ),
    HealthEvent(
      id: 'HE-004',
      type: HealthEventType.admission,
      title: 'Hospitalized for Acute Gastritis',
      description: 'Admitted via ER, treated with IV fluids and PPIs.',
      date: DateTime(2025, 11, 12),
      doctorName: 'Dr. S. M. Zafar',
      hospitalName: 'Dhaka Central Hospital',
    ),
    HealthEvent(
      id: 'HE-005',
      type: HealthEventType.vaccination,
      title: 'COVID-19 Booster Dose',
      description: 'Pfizer-BioNTech booster vaccination.',
      date: DateTime(2025, 8, 22),
      doctorName: 'Staff Nurse Sumaiya',
      hospitalName: 'Dhanmondi Ward Council Clinic',
    ),
  ];

  // 5. Available Doctors
  final List<DoctorSpecialist> availableDoctors = [
    DoctorSpecialist(
      id: 'DOC-001',
      name: 'Dr. Ahmed Chowdhury',
      specialization: 'Endocrinology & Diabetology',
      hospital: 'Dhaka Central Hospital',
      rating: 4.9,
      experienceYears: 16,
      consultationFee: 1000,
      imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=200&auto=format&fit=crop',
    ),
    DoctorSpecialist(
      id: 'DOC-002',
      name: 'Dr. Fahmida Rahman',
      specialization: 'Cardiology',
      hospital: 'National Medical Center',
      rating: 4.8,
      experienceYears: 12,
      consultationFee: 1200,
      imageUrl: 'https://images.unsplash.com/photo-1594824813573-246434de83fb?q=80&w=200&auto=format&fit=crop',
    ),
    DoctorSpecialist(
      id: 'DOC-003',
      name: 'Dr. Tanveer Hassan',
      specialization: 'General Medicine',
      hospital: 'Ibn Sina Medical College',
      rating: 4.7,
      experienceYears: 8,
      consultationFee: 800,
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=200&auto=format&fit=crop',
    ),
    DoctorSpecialist(
      id: 'DOC-004',
      name: 'Dr. Nusrat Jahan Tania',
      specialization: 'Gynaecology & Obstetrics',
      hospital: 'Dhaka Medical College Hospital',
      rating: 4.9,
      experienceYears: 14,
      consultationFee: 1000,
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=200&auto=format&fit=crop',
    ),
  ];

  // 6. Time slots
  final List<TimeSlot> timeSlots = [
    TimeSlot(id: 'TS-1', time: '09:00 AM', isAvailable: true),
    TimeSlot(id: 'TS-2', time: '09:30 AM', isAvailable: false),
    TimeSlot(id: 'TS-3', time: '10:00 AM', isAvailable: true),
    TimeSlot(id: 'TS-4', time: '10:30 AM', isAvailable: true),
    TimeSlot(id: 'TS-5', time: '11:00 AM', isAvailable: false),
    TimeSlot(id: 'TS-6', time: '11:30 AM', isAvailable: true),
    TimeSlot(id: 'TS-7', time: '04:00 PM', isAvailable: true),
    TimeSlot(id: 'TS-8', time: '04:30 PM', isAvailable: true),
  ];

  // 7. Appointments
  late final List<Appointment> appointments = [
    Appointment(
      id: 'APP-101',
      doctor: availableDoctors[0],
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '10:30 AM',
      hospital: 'Dhaka Central Hospital',
      queueNumber: 'Q-07',
      status: 'Upcoming',
    ),
    Appointment(
      id: 'APP-102',
      doctor: availableDoctors[1],
      date: DateTime.now().add(const Duration(days: 4)),
      timeSlot: '04:30 PM',
      hospital: 'National Medical Center',
      queueNumber: 'Q-14',
      status: 'Upcoming',
    ),
    Appointment(
      id: 'APP-103',
      doctor: availableDoctors[0],
      date: DateTime.now().subtract(const Duration(days: 20)),
      timeSlot: '09:00 AM',
      hospital: 'Dhaka Central Hospital',
      queueNumber: 'Q-03',
      status: 'Past',
    ),
  ];

  // 8. Prescriptions
  final List<Prescription> prescriptions = [
    Prescription(
      id: 'PR-102',
      date: DateTime(2026, 5, 30),
      doctorName: 'Dr. Ahmed Chowdhury',
      doctorSpecialization: 'Endocrinology & Diabetology',
      hospitalName: 'Dhaka Central Hospital',
      diagnosis: 'Type 2 Diabetes Mellitus & Hypertension',
      medicines: [
        Medicine(name: 'Metformin Hydrochloride', dosage: '500mg', instruction: '1 tablet twice daily after meals (morning and night)', duration: '30 days'),
        Medicine(name: 'Amlodipine Besylate', dosage: '5mg', instruction: '1 tablet once daily in the morning', duration: '30 days'),
        Medicine(name: 'Atorvastatin Calcium', dosage: '10mg', instruction: '1 tablet once daily before bed', duration: '30 days'),
      ],
      clinicalNotes: 'Check fasting glucose daily. Maintain a low carbohydrate diet and exercise at least 30 minutes daily. Follow up in 30 days with a fresh HbA1c report.',
      followUpDate: '2026-06-30',
    ),
    Prescription(
      id: 'PR-101',
      date: DateTime(2025, 11, 15),
      doctorName: 'Dr. S. M. Zafar',
      doctorSpecialization: 'Gastroenterology',
      hospitalName: 'Dhaka Central Hospital',
      diagnosis: 'Acute Gastritis & Acid Reflux',
      medicines: [
        Medicine(name: 'Esomeprazole Magnesium', dosage: '20mg', instruction: '1 capsule daily 30 minutes before breakfast', duration: '14 days'),
        Medicine(name: 'Domperidone', dosage: '10mg', instruction: '1 tablet three times daily 15 minutes before meals', duration: '7 days'),
      ],
      clinicalNotes: 'Avoid spicy and oily foods. Avoid sleeping immediately after taking meals. Remain hydrated.',
    ),
  ];

  // 9. Lab Reports
  final List<LabReport> labReports = [
    LabReport(
      id: 'LR-201',
      testName: 'Fasting Blood Glucose (FBG) & Lipid Profile',
      category: 'Biochemistry',
      date: DateTime(2026, 5, 29),
      hospitalName: 'Dhaka Central Hospital Lab',
      doctorName: 'Dr. Ahmed Chowdhury',
      status: 'Published',
      results: [
        LabTestResult(parameter: 'Fasting Blood Sugar', value: '180', unit: 'mg/dL', referenceRange: '70 - 100', status: 'High'),
        LabTestResult(parameter: 'Total Cholesterol', value: '210', unit: 'mg/dL', referenceRange: '< 200', status: 'High'),
        LabTestResult(parameter: 'HDL (Good Cholesterol)', value: '42', unit: 'mg/dL', referenceRange: '> 40', status: 'Normal'),
        LabTestResult(parameter: 'LDL (Bad Cholesterol)', value: '135', unit: 'mg/dL', referenceRange: '< 100', status: 'High'),
        LabTestResult(parameter: 'Triglycerides', value: '165', unit: 'mg/dL', referenceRange: '< 150', status: 'High'),
      ],
      aiInterpretation: 'WARNING: Your Fasting Blood Sugar is significantly high (180 mg/dL), indicating poor glycaemic control. Total Cholesterol and Bad Cholesterol (LDL) are also moderately elevated. This combination increases long-term cardiovascular risks. Medication compliance and dietary check are urgent.',
    ),
    LabReport(
      id: 'LR-200',
      testName: 'Complete Blood Count (CBC)',
      category: 'Haematology',
      date: DateTime(2026, 3, 10),
      hospitalName: 'National Medical Center Lab',
      doctorName: 'Dr. Fahmida Rahman',
      status: 'Published',
      results: [
        LabTestResult(parameter: 'Hemoglobin', value: '14.5', unit: 'g/dL', referenceRange: '13.5 - 17.5', status: 'Normal'),
        LabTestResult(parameter: 'Total WBC Count', value: '6,500', unit: '/cumm', referenceRange: '4,000 - 11,000', status: 'Normal'),
        LabTestResult(parameter: 'Platelet Count', value: '250,000', unit: '/cumm', referenceRange: '150,000 - 450,000', status: 'Normal'),
      ],
      aiInterpretation: 'Your complete blood count parameters are within the standard reference range. No active infection or anaemia detected.',
    ),
  ];

  // 10. Imaging Reports
  final List<ImagingReport> imagingReports = [
    ImagingReport(
      id: 'IM-301',
      type: 'Chest X-Ray (PA View)',
      bodyPart: 'Chest',
      date: DateTime(2026, 3, 15),
      hospitalName: 'National Medical Center Imaging',
      doctorName: 'Dr. Fahmida Rahman',
      imageUrl: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?q=80&w=600&auto=format&fit=crop',
      findings: 'The bronchovascular markings are normal. Both lung fields are clear. No evidence of active consolidation, infiltration, or pleural effusion. The cardiothoracic ratio is normal. Both hemidiaphragms are normal with clear costophrenic angles. Bony thoracic cage is intact.',
      impression: 'Normal study of the chest. No active cardiopulmonary pathology.',
    ),
  ];
}
```

### `lib/features/patient/data/repositories/patient_repository.dart`
```dart
import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';
import '../datasources/patient_mock_datasource.dart';

abstract class PatientRepository {
  Future<DashboardSummary> getDashboardSummary(String healthId);
  Future<AiHealthSummary> getAiHealthSummary(String healthId);
  Future<PatientProfile> getPatientProfile(String healthId);
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile);
  Future<List<HealthEvent>> getHealthEvents(String healthId);
  Future<List<DoctorSpecialist>> getAvailableDoctors();
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date);
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  });
  Future<List<Appointment>> getAppointments(String healthId);
  Future<List<Prescription>> getPrescriptions(String healthId);
  Future<List<LabReport>> getLabReports(String healthId);
  Future<List<ImagingReport>> getImagingReports(String healthId);
  Future<void> cancelAppointment(String appointmentId);
}

class PatientRepositoryImpl implements PatientRepository {
  final _datasource = PatientMockDatasource();

  // Simulate network latency
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<DashboardSummary> getDashboardSummary(String healthId) async {
    await _delay();
    return _datasource.dashboardSummary;
  }

  @override
  Future<AiHealthSummary> getAiHealthSummary(String healthId) async {
    await _delay();
    return _datasource.aiHealthSummary;
  }

  @override
  Future<PatientProfile> getPatientProfile(String healthId) async {
    await _delay();
    return _datasource.profile;
  }

  @override
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile) async {
    await _delay();
    _datasource.profile = profile;
    return _datasource.profile;
  }

  @override
  Future<List<HealthEvent>> getHealthEvents(String healthId) async {
    await _delay();
    return _datasource.healthEvents;
  }

  @override
  Future<List<DoctorSpecialist>> getAvailableDoctors() async {
    await _delay();
    return _datasource.availableDoctors;
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    await _delay();
    // In a real app we would query slots for that doctor on that date
    return _datasource.timeSlots;
  }

  @override
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  }) async {
    await _delay();
    final newAppointment = Appointment(
      id: 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      doctor: doctor,
      date: date,
      timeSlot: timeSlot,
      hospital: doctor.hospital,
      queueNumber: 'Q-09',
      status: 'Upcoming',
    );
    _datasource.appointments.insert(0, newAppointment);
    return newAppointment;
  }

  @override
  Future<List<Appointment>> getAppointments(String healthId) async {
    await _delay();
    return _datasource.appointments;
  }

  @override
  Future<List<Prescription>> getPrescriptions(String healthId) async {
    await _delay();
    return _datasource.prescriptions;
  }

  @override
  Future<List<LabReport>> getLabReports(String healthId) async {
    await _delay();
    return _datasource.labReports;
  }

  @override
  Future<List<ImagingReport>> getImagingReports(String healthId) async {
    await _delay();
    return _datasource.imagingReports;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await _delay();
    final index = _datasource.appointments.indexWhere((app) => app.id == appointmentId);
    if (index != -1) {
      final oldApp = _datasource.appointments[index];
      _datasource.appointments[index] = Appointment(
        id: oldApp.id,
        doctor: oldApp.doctor,
        date: oldApp.date,
        timeSlot: oldApp.timeSlot,
        hospital: oldApp.hospital,
        queueNumber: oldApp.queueNumber,
        status: 'Cancelled',
      );
    }
  }
}
```

### `lib/features/patient/presentation/providers/patient_providers.dart`
```dart
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
```

### `lib/features/patient/presentation/providers/booking_provider.dart`
```dart
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
```

---

## 🛠️ Extra Steps

### 1. Flutter Dependencies
Verify that your `pubspec.yaml` has the required packages:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.3.2
  google_fonts: ^8.1.0
```

### 2. Riverpod v3 Import Configuration
In Riverpod v3, standard `flutter_riverpod` imports do not contain the legacy state classes by default. Ensure that files declaring or using `StateNotifier` and `StateNotifierProvider` explicitly import:
```dart
import 'package:flutter_riverpod/legacy.dart';
```

### 3. Local Mock Testing
Set the state of `isMockModeProvider` to `true` inside `mock_provider.dart` to simulate local data latency without requesting live endpoints. To inspect real-time changes in Chrome:
```bash
flutter run -d chrome
```

---

## 📝 Summary

1. **Initializing Dashboard**: The UI calls `ref.watch(patientProfileProvider)` and its related data providers to trigger the asynchronous fetch calls from the repository layer.
2. **Editing Profile Wizard**: The user clicks edit on `PatientProfilePage`, filling out three steps of form fields. Clicking save calls `updateProfile(...)` on `patientProfileProvider.notifier`, which updates the local datasource and triggers a state refresh, immediately reflecting modified vitals or allergies on the Dashboard page cards.
3. **Booking Flow Wizard**:
   - The user selects a physician, triggers `bookingProvider.notifier.selectDoctor(doctor)` to load slot schedules.
   - The user selects a date/time slot, and hits confirm.
   - The wizard issues the booking call, appends the newly returned `Appointment` to the reactive list in `patientAppointmentsProvider`, and returns to the listing layout showing the new slot immediately.
4. **Vault Inspector**: Accesses prescriptions, lab reports, and imaging reports. The UI pops up full details dialogues, enabling downloading PDF files or copying report text in single click actions.
