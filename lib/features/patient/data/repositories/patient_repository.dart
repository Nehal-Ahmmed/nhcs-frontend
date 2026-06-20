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
