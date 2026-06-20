import '../models/hospital_dashboard_stats.dart';
import '../models/reception_queue_item.dart';
import '../models/staff_member.dart';
import '../models/lab_test_order.dart';
import '../models/bed_allocation.dart';
import '../models/pharmacy_item.dart';

class HospitalMockDatasource {
  static final HospitalMockDatasource _instance = HospitalMockDatasource._internal();
  factory HospitalMockDatasource() => _instance;
  HospitalMockDatasource._internal() {
    _init();
  }

  late HospitalDashboardStats dashboardStats;
  late List<ReceptionQueueItem> receptionQueue;
  late List<StaffMember> staffMembers;
  late List<DoctorVerificationRequest> verificationRequests;
  late List<LabTestOrder> labOrders;
  late List<BedAllocation> beds;
  late List<PharmacyItem> pharmacyItems;
  late Map<String, Map<String, dynamic>> mockPrescriptions;

  void _init() {
    dashboardStats = HospitalDashboardStats(
      activePatients: 184,
      bedOccupancyRate: 80.8,
      totalBeds: 250,
      occupiedBeds: 202,
      onDutyStaff: 24,
      onDutyDoctors: 10,
      onDutyNurses: 14,
      emergencyIntake: 5,
      criticalCases: 3,
      alerts: [
        OperationalAlert(id: 'a1', title: 'Critical Bed Capacity', description: 'ICU Occupancy is at 94% (15/16 beds occupied).', timeAgo: 'Just now', type: 'danger'),
        OperationalAlert(id: 'a2', title: 'Medicine Shortage', description: 'Paracetamol 500mg stock is below 1,000 tablets.', timeAgo: '10 mins ago', type: 'warning'),
        OperationalAlert(id: 'a3', title: 'Ambulance Out of Service', description: 'Ambulance #3 is offline for maintenance.', timeAgo: '1 hour ago', type: 'info'),
      ],
      departmentLoads: [
        DepartmentLoad(name: 'Emergency', patients: 28, staff: 5, load: 'Critical'),
        DepartmentLoad(name: 'Cardiology', patients: 15, staff: 3, load: 'High'),
        DepartmentLoad(name: 'ICU', patients: 14, staff: 4, load: 'Critical'),
        DepartmentLoad(name: 'General Ward', patients: 82, staff: 8, load: 'Normal'),
        DepartmentLoad(name: 'Pediatrics', patients: 22, staff: 2, load: 'Normal'),
        DepartmentLoad(name: 'Outpatient (OPD)', patients: 23, staff: 2, load: 'Normal'),
      ],
    );

    receptionQueue = [
      ReceptionQueueItem(queueNo: 'EM-04', name: 'Hasan Ali', age: '52', gender: 'M', dept: 'Emergency', doctor: 'Trauma Lead', status: 'In Consultation'),
      ReceptionQueueItem(queueNo: 'EM-05', name: 'Fatema Zohra', age: '24', gender: 'F', dept: 'Emergency', doctor: 'Dr. Subrata', status: 'Waiting'),
      ReceptionQueueItem(queueNo: 'CD-01', name: 'Abdul Karim', age: '62', gender: 'M', dept: 'Cardiology', doctor: 'Dr. Ahmed Khan', status: 'In Consultation'),
    ];

    staffMembers = [
      StaffMember(id: 'S-001', name: 'Dr. Ahmed Khan', role: 'Doctor', dept: 'Cardiology', status: 'Active', shifts: {'Monday': '8 AM - 2 PM', 'Wednesday': 'Cardiology Department'}),
      StaffMember(id: 'S-002', name: 'Dr. Subrata Sen', role: 'Doctor', dept: 'Emergency', status: 'Active', shifts: {'Monday': '2 PM - 8 PM', 'Tuesday': 'Emergency Duty'}),
      StaffMember(id: 'S-003', name: 'Dr. Fatima', role: 'Doctor', dept: 'General Ward', status: 'Active', shifts: {'Tuesday': '8 AM - 2 PM', 'Thursday': 'General Ward Duty'}),
      StaffMember(id: 'S-004', name: 'Trauma Lead', role: 'Doctor', dept: 'Emergency', status: 'Active', shifts: {'Everyday': 'Emergency Shift'}),
      StaffMember(id: 'S-005', name: 'Staff Nurse Sumaiya', role: 'Nurse', dept: 'ICU', status: 'Active', shifts: {'Monday': '8 AM - 4 PM'}),
      StaffMember(id: 'S-006', name: 'Lab Tech Hasan', role: 'Technician', dept: 'Laboratory', status: 'Active', shifts: {'Monday': '9 AM - 5 PM'}),
    ];

    verificationRequests = [
      DoctorVerificationRequest(id: 'req-01', name: 'Dr. Tahmid Rahman', bmdcNo: 'BMDC-88192', specialization: 'Neurology', date: 'June 18, 2026', status: 'Pending'),
      DoctorVerificationRequest(id: 'req-02', name: 'Dr. Sabrina Yasmin', bmdcNo: 'BMDC-90211', specialization: 'Pediatrics', date: 'June 17, 2026', status: 'Pending'),
    ];

    labOrders = [
      LabTestOrder(id: 'LB-101', patient: 'Rahim Islam', healthId: 'NUD-892-441-X7', test: 'Complete Blood Count (CBC)', doctor: 'Dr. Ahmed Khan', status: 'Ordered', results: {}),
      LabTestOrder(id: 'LB-102', patient: 'Jahanara Begum', healthId: 'NUD-123-456-A1', test: 'Fasting Blood Glucose', doctor: 'Trauma Lead', status: 'Sample Collected', results: {}),
      LabTestOrder(id: 'LB-103', patient: 'Kamal Hossain', healthId: 'NUD-987-654-B2', test: 'Lipid Profile', doctor: 'Dr. Fatima', status: 'Processing', results: {}),
      LabTestOrder(id: 'LB-104', patient: 'Abdul Karim', healthId: 'NUD-111-222-A2', test: 'Serum Creatinine', doctor: 'Dr. Ahmed Khan', status: 'Verified', results: {'Creatinine': '1.1 mg/dL'}),
      LabTestOrder(id: 'LB-105', patient: 'Hasan Ali', healthId: 'NUD-444-555-C3', test: 'ECG / Electrocardiogram', doctor: 'Trauma Lead', status: 'Published', results: {'Rhythm': 'Normal Sinus Rhythm'}),
    ];

    beds = [
      BedAllocation(id: 'B-101', ward: 'General Ward (Male)', number: 'Bed 101', status: 'Occupied', patient: 'Rahim Islam', healthId: 'NUD-892-441-X7', doctor: 'Dr. Ahmed Khan', days: 3),
      BedAllocation(id: 'B-102', ward: 'General Ward (Male)', number: 'Bed 102', status: 'Available'),
      BedAllocation(id: 'B-103', ward: 'General Ward (Male)', number: 'Bed 103', status: 'Available'),
      BedAllocation(id: 'B-104', ward: 'General Ward (Male)', number: 'Bed 104', status: 'Maintenance'),
      BedAllocation(id: 'B-105', ward: 'General Ward (Male)', number: 'Bed 105', status: 'Available'),
      BedAllocation(id: 'B-106', ward: 'General Ward (Male)', number: 'Bed 106', status: 'Occupied', patient: 'Kamal Hossain', healthId: 'NUD-987-654-B2', doctor: 'Dr. Fatima', days: 1),
      
      BedAllocation(id: 'B-201', ward: 'General Ward (Female)', number: 'Bed 201', status: 'Occupied', patient: 'Jahanara Begum', healthId: 'NUD-123-456-A1', doctor: 'Dr. Fatima', days: 2),
      BedAllocation(id: 'B-202', ward: 'General Ward (Female)', number: 'Bed 202', status: 'Available'),
      BedAllocation(id: 'B-203', ward: 'General Ward (Female)', number: 'Bed 203', status: 'Available'),
      BedAllocation(id: 'B-204', ward: 'General Ward (Female)', number: 'Bed 204', status: 'Available'),
      
      BedAllocation(id: 'B-301', ward: 'ICU', number: 'Bed 301', status: 'Occupied', patient: 'Hasan Ali', healthId: 'NUD-444-555-C3', doctor: 'Trauma Lead', days: 5),
      BedAllocation(id: 'B-302', ward: 'ICU', number: 'Bed 302', status: 'Available'),
    ];

    pharmacyItems = [
      PharmacyItem(name: 'Metformin 500mg', generic: 'Metformin HCl', category: 'Antidiabetic', stock: 5000, min: 1000, price: 'BDT 5.00'),
      PharmacyItem(name: 'Amlodipine 5mg', generic: 'Amlodipine Besylate', category: 'Antihypertensive', stock: 2400, min: 500, price: 'BDT 8.00'),
      PharmacyItem(name: 'Aspirin 75mg', generic: 'Acetylsalicylic Acid', category: 'Antiplatelet', stock: 1800, min: 500, price: 'BDT 2.00'),
      PharmacyItem(name: 'Paracetamol 500mg', generic: 'Acetaminophen', category: 'Analgesic', stock: 400, min: 1000, price: 'BDT 1.50'),
      PharmacyItem(name: 'Amoxicillin 500mg', generic: 'Amoxicillin Trihydrate', category: 'Antibiotic', stock: 1200, min: 300, price: 'BDT 12.00'),
      PharmacyItem(name: 'Atorvastatin 10mg', generic: 'Atorvastatin Calcium', category: 'Cardiovascular', stock: 150, min: 500, price: 'BDT 15.00'),
    ];

    mockPrescriptions = {
      'RX-9921': {
        'patient': 'Rahim Islam',
        'id': 'RX-9921',
        'doctor': 'Dr. Ahmed Khan',
        'date': 'Jun 15, 2026',
        'items': [
          {'medicine': 'Metformin 500mg', 'qty': 60, 'instruction': '1 tablet twice daily after meals'},
          {'medicine': 'Amlodipine 5mg', 'qty': 30, 'instruction': '1 tablet daily in morning'},
        ]
      },
      'RX-1024': {
        'patient': 'Jahanara Begum',
        'id': 'RX-1024',
        'doctor': 'Dr. Fatima',
        'date': 'Jun 14, 2026',
        'items': [
          {'medicine': 'Amoxicillin 500mg', 'qty': 21, 'instruction': '1 tablet 3 times daily for 7 days'},
          {'medicine': 'Paracetamol 500mg', 'qty': 10, 'instruction': '1 tablet as needed for pain'},
        ]
      }
    };
  }

  void updateOccupancyStats() {
    int total = beds.length;
    int occupied = beds.where((b) => b.status == 'Occupied').length;
    double rate = (occupied / total) * 100.0;
    dashboardStats = dashboardStats.copyWith(
      occupiedBeds: occupied,
      totalBeds: total,
      bedOccupancyRate: double.parse(rate.toStringAsFixed(1)),
    );
  }
}
