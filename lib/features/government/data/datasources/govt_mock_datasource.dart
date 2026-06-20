import '../models/govt_dashboard_stats.dart';
import '../models/govt_registry_models.dart';
import '../models/govt_resource_models.dart';
import '../models/govt_audit_event.dart';

class GovtMockDatasource {
  static final GovtMockDatasource _instance = GovtMockDatasource._internal();
  factory GovtMockDatasource() => _instance;
  GovtMockDatasource._internal() {
    _init();
  }

  late GovtDashboardStats dashboardStats;
  late List<CitizenProfile> citizens;
  late List<DoctorProfile> doctors;
  late List<HospitalProfile> hospitals;
  late List<RegionalResource> regionalResources;
  late List<GovtAuditEvent> auditEvents;

  void _init() {
    citizens = [
      const CitizenProfile(healthId: 'NUD-892-441-X7', name: 'Rahim Islam', age: 52, gender: 'M', division: 'Dhaka', bloodGroup: 'O+', registrationDate: '2026-05-10'),
      const CitizenProfile(healthId: 'NUD-123-456-A1', name: 'Jahanara Begum', age: 29, gender: 'F', division: 'Chittagong', bloodGroup: 'A+', registrationDate: '2026-03-22'),
      const CitizenProfile(healthId: 'NUD-987-654-B2', name: 'Kamal Hossain', age: 41, gender: 'M', division: 'Sylhet', bloodGroup: 'B+', registrationDate: '2026-04-12'),
      const CitizenProfile(healthId: 'NUD-444-555-C3', name: 'Fatema Zohra', age: 24, gender: 'F', division: 'Dhaka', bloodGroup: 'AB+', registrationDate: '2026-06-18'),
      const CitizenProfile(healthId: 'NUD-111-222-A2', name: 'Hasan Ali', age: 62, gender: 'M', division: 'Rajshahi', bloodGroup: 'O-', registrationDate: '2026-01-15'),
      const CitizenProfile(healthId: 'NUD-555-666-D4', name: 'Abdul Karim', age: 70, gender: 'M', division: 'Barisal', bloodGroup: 'B-', registrationDate: '2026-02-28'),
      const CitizenProfile(healthId: 'NUD-777-888-E5', name: 'Nigar Sultana', age: 33, gender: 'F', division: 'Khulna', bloodGroup: 'A-', registrationDate: '2026-06-05'),
      const CitizenProfile(healthId: 'NUD-333-444-F6', name: 'Tanjil Ahmed', age: 22, gender: 'M', division: 'Mymensingh', bloodGroup: 'O+', registrationDate: '2026-06-12'),
    ];

    doctors = [
      const DoctorProfile(bmdcId: 'BMDC-88192', name: 'Dr. Ahmed Khan', specialization: 'Cardiology', affiliatedHospital: 'Dhaka General Hospital', status: 'Active', registrationDate: '2024-05-12'),
      const DoctorProfile(bmdcId: 'BMDC-90211', name: 'Dr. Subrata Sen', specialization: 'Emergency Medicine', affiliatedHospital: 'Chittagong Medical Center', status: 'Active', registrationDate: '2025-01-18'),
      const DoctorProfile(bmdcId: 'BMDC-77341', name: 'Dr. Fatima', specialization: 'General Medicine', affiliatedHospital: 'Sylhet Specialized Care', status: 'Active', registrationDate: '2025-06-02'),
      const DoctorProfile(bmdcId: 'BMDC-92144', name: 'Dr. Sabrina Yasmin', specialization: 'Pediatrics', affiliatedHospital: 'Kurmitola General Hospital', status: 'Active', registrationDate: '2026-06-17'),
      const DoctorProfile(bmdcId: 'BMDC-81729', name: 'Dr. Tahmid Rahman', specialization: 'Neurology', affiliatedHospital: 'NINS Dhaka', status: 'Suspended', registrationDate: '2023-11-20'),
      const DoctorProfile(bmdcId: 'BMDC-65239', name: 'Dr. Anisur Rahman', specialization: 'Orthopedics', affiliatedHospital: 'Rajshahi Health Clinic', status: 'Active', registrationDate: '2022-08-15'),
      const DoctorProfile(bmdcId: 'BMDC-74918', name: 'Dr. Sharmin Akter', specialization: 'Gynecology', affiliatedHospital: 'Mymensingh Medical College', status: 'Active', registrationDate: '2024-10-04'),
    ];

    hospitals = [
      const HospitalProfile(facilityId: 'H-101', name: 'Dhaka General Hospital', division: 'Dhaka', classification: 'General', totalBeds: 250, occupiedBeds: 202, complianceScore: 94.0, status: 'Licensed'),
      const HospitalProfile(facilityId: 'H-102', name: 'Chittagong Medical Center', division: 'Chittagong', classification: 'General', totalBeds: 200, occupiedBeds: 160, complianceScore: 88.0, status: 'Licensed'),
      const HospitalProfile(facilityId: 'H-103', name: 'Sylhet Specialized Care', division: 'Sylhet', classification: 'Specialized', totalBeds: 120, occupiedBeds: 90, complianceScore: 91.5, status: 'Licensed'),
      const HospitalProfile(facilityId: 'H-104', name: 'Rajshahi Health Clinic', division: 'Rajshahi', classification: 'Clinic', totalBeds: 50, occupiedBeds: 15, complianceScore: 75.0, status: 'Licensed'),
      const HospitalProfile(facilityId: 'H-105', name: 'Khulna District Hospital', division: 'Khulna', classification: 'General', totalBeds: 150, occupiedBeds: 110, complianceScore: 82.5, status: 'Under Review'),
      const HospitalProfile(facilityId: 'H-106', name: 'Barisal Community Hospital', division: 'Barisal', classification: 'General', totalBeds: 100, occupiedBeds: 85, complianceScore: 55.0, status: 'Suspended'),
    ];

    regionalResources = [
      const RegionalResource(division: 'Dhaka', activeWorkforce: 1250, ventilatorCount: 85, oxygenReserves: 12000, totalBeds: 2200, occupiedBeds: 1850, workforceGap: 'Low'),
      const RegionalResource(division: 'Chittagong', activeWorkforce: 750, ventilatorCount: 45, oxygenReserves: 8000, totalBeds: 1400, occupiedBeds: 1120, workforceGap: 'Moderate'),
      const RegionalResource(division: 'Sylhet', activeWorkforce: 420, ventilatorCount: 25, oxygenReserves: 5500, totalBeds: 800, occupiedBeds: 680, workforceGap: 'High'),
      const RegionalResource(division: 'Rajshahi', activeWorkforce: 380, ventilatorCount: 18, oxygenReserves: 4200, totalBeds: 750, occupiedBeds: 450, workforceGap: 'Low'),
      const RegionalResource(division: 'Khulna', activeWorkforce: 340, ventilatorCount: 15, oxygenReserves: 3800, totalBeds: 600, occupiedBeds: 480, workforceGap: 'Moderate'),
      const RegionalResource(division: 'Barisal', activeWorkforce: 220, ventilatorCount: 10, oxygenReserves: 2500, totalBeds: 450, occupiedBeds: 360, workforceGap: 'High'),
      const RegionalResource(division: 'Mymensingh', activeWorkforce: 290, ventilatorCount: 12, oxygenReserves: 3000, totalBeds: 500, occupiedBeds: 380, workforceGap: 'Moderate'),
      const RegionalResource(division: 'Rangpur', activeWorkforce: 250, ventilatorCount: 8, oxygenReserves: 2200, totalBeds: 400, occupiedBeds: 310, workforceGap: 'High'),
    ];

    auditEvents = [
      const GovtAuditEvent(id: 'au-1', action: 'Facility Audited', target: 'Dhaka General Hospital', description: 'Compliance score updated to 94% following standard physical audit.', timestamp: 'June 18, 2026, 11:30 AM', operator: 'Dr. Aminul Islam (MoHFW)', status: 'success'),
      const GovtAuditEvent(id: 'au-2', action: 'License Suspended', target: 'Barisal Community Hospital', description: 'Facility license suspended due to severe clinical quality code violations.', timestamp: 'June 15, 2026, 04:15 PM', operator: 'MoHFW Registry Board', status: 'warning'),
      const GovtAuditEvent(id: 'au-3', action: 'Practitioner Suspended', target: 'Dr. Tahmid Rahman', description: 'BMDC-81729 suspended pending medical negligence inquiry.', timestamp: 'June 10, 2026, 10:00 AM', operator: 'BMDC Registry Committee', status: 'danger'),
    ];

    dashboardStats = GovtDashboardStats(
      totalRegisteredCitizens: 12450,
      totalRegisteredDoctors: doctors.length,
      totalLicensedHospitals: hospitals.where((h) => h.status == 'Licensed').length,
      activeDiseaseOutbreaks: 2,
      nationalBedOccupancyRate: _calculateNationalOccupancy(),
      alerts: [
        const NationalAlert(id: 'g1', title: 'Dengue Surge (Dhaka)', description: 'Daily Dengue cases exceeded critical threshold in Dhaka North.', timeAgo: '2 hours ago', type: 'danger', division: 'Dhaka'),
        const NationalAlert(id: 'g2', title: 'Workforce Deficit (Chittagong)', description: 'Nurses and clinical staff capacity short by 25% in Chittagong Division General Ward.', timeAgo: '1 day ago', type: 'warning', division: 'Chittagong'),
      ],
      outbreaks: [
        const OutbreakStat(id: 'o1', diseaseName: 'Dengue Fever', activeCases: 1250, weeklyNewCases: 340, riskLevel: 'High', trend: 'Rising', affectedAreas: 'Dhaka, Chittagong, Barisal'),
        const OutbreakStat(id: 'o2', diseaseName: 'COVID-19 (JN.1)', activeCases: 210, weeklyNewCases: 15, riskLevel: 'Low', trend: 'Stable', affectedAreas: 'Dhaka, Sylhet'),
        const OutbreakStat(id: 'o3', diseaseName: 'Chikungunya', activeCases: 95, weeklyNewCases: 30, riskLevel: 'Moderate', trend: 'Rising', affectedAreas: 'Rajshahi, Khulna'),
        const OutbreakStat(id: 'o4', diseaseName: 'Cholera Outbreak', activeCases: 500, weeklyNewCases: 150, riskLevel: 'High', trend: 'Rising', affectedAreas: 'Sylhet, Mymensingh'),
      ],
    );
  }

  double _calculateNationalOccupancy() {
    int total = 0;
    int occupied = 0;
    for (var h in hospitals) {
      total += h.totalBeds;
      occupied += h.occupiedBeds;
    }
    if (total == 0) return 0.0;
    return double.parse(((occupied / total) * 100.0).toStringAsFixed(1));
  }

  void recalculateDashboardStats() {
    dashboardStats = dashboardStats.copyWith(
      totalRegisteredCitizens: citizens.length + 12442, // offset for mock numbers
      totalRegisteredDoctors: doctors.length,
      totalLicensedHospitals: hospitals.where((h) => h.status == 'Licensed').length,
      nationalBedOccupancyRate: _calculateNationalOccupancy(),
      activeDiseaseOutbreaks: dashboardStats.outbreaks.where((o) => o.riskLevel == 'High' || o.riskLevel == 'Moderate').length,
    );
  }
}
