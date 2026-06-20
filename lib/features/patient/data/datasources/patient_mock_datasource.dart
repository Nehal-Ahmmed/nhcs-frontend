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
