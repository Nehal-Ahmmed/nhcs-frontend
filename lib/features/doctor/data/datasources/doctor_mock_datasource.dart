import '../models/doctor_dashboard_summary.dart';
import '../models/patient_queue_item.dart';
import '../models/report_review_item.dart';
import '../models/clinical_case.dart';

class DoctorMockDatasource {
  static final DoctorMockDatasource _instance = DoctorMockDatasource._internal();
  factory DoctorMockDatasource() => _instance;
  DoctorMockDatasource._internal();

  // 1. Dashboard summary
  final DoctorDashboardSummary dashboardSummary = DoctorDashboardSummary(
    totalAppointments: 18,
    totalFollowUps: 8,
    emergencyCases: 2,
    pendingReports: 5,
    referredCases: 3,
    aiBriefing: "Good morning Dr. Ahmed. Today you have 18 consultations, including 8 diabetes follow-ups, 2 cardiac emergency reviews, and 3 referrals from local general practitioners. Your first patient is Rahim Islam, scheduled at 08:00 AM, who has a history of Type 2 Diabetes and Hypertension, showing elevated blood glucose trends.",
  );

  // 2. Patient Queue
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

  // 3. Pending Reports to Review
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

  // 4. Doctor Weekly Schedule slots
  final Map<String, List<String>> scheduleSlots = {
    'Monday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'],
    'Tuesday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM'],
    'Wednesday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'],
    'Thursday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM'],
    'Friday': ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM'],
  };

  // 5. Submitted Clinical Cases (Saved history)
  final List<TreatmentPlan> submittedTreatmentPlans = [];

  void addTreatmentPlan(TreatmentPlan plan) {
    submittedTreatmentPlans.add(plan);
  }
}
