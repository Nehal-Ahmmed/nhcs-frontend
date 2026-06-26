import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';
import '../datasources/patient_mock_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

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
  final Dio dio;
  final bool isMock;
  final _mockDatasource = PatientMockDatasource();

  PatientRepositoryImpl(this.dio, this.isMock);

  // Simulate network latency (only in mock mode)
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<DashboardSummary> getDashboardSummary(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.dashboardSummary;
    }
    final response = await dio.get(ApiEndpoints.patientDashboardSummary);
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AiHealthSummary> getAiHealthSummary(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.aiHealthSummary;
    }
    final response = await dio.get(ApiEndpoints.patientAiSummary);
    return AiHealthSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> getPatientProfile(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.profile;
    }
    final response = await dio.get(ApiEndpoints.patientProfile);
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile) async {
    if (isMock) {
      await _delay();
      _mockDatasource.profile = profile;
      return _mockDatasource.profile;
    }
    final response = await dio.put(
      ApiEndpoints.patientProfile,
      data: profile.toJson(),
    );
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<HealthEvent>> getHealthEvents(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.healthEvents;
    }
    final response = await dio.get(ApiEndpoints.patientTimeline);
    final list = response.data as List<dynamic>;
    return list.map((e) => HealthEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorSpecialist>> getAvailableDoctors() async {
    if (isMock) {
      await _delay();
      return _mockDatasource.availableDoctors;
    }
    final response = await dio.get(ApiEndpoints.doctorsList);
    final list = response.data as List<dynamic>;
    return list.map((e) => DoctorSpecialist.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.timeSlots;
    }
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await dio.get(
      ApiEndpoints.doctorSlots(doctorId),
      queryParameters: {'date': dateStr},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Appointment> bookAppointment({
    required String healthId,
    required DoctorSpecialist doctor,
    required DateTime date,
    required String timeSlot,
  }) async {
    if (isMock) {
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
      _mockDatasource.appointments.insert(0, newAppointment);
      return newAppointment;
    }
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await dio.post(
      ApiEndpoints.patientAppointments,
      data: {
        'doctorId': doctor.id,
        'date': dateStr,
        'timeSlot': timeSlot,
      },
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Appointment>> getAppointments(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.appointments;
    }
    final response = await dio.get(ApiEndpoints.patientAppointments);
    final list = response.data as List<dynamic>;
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Prescription>> getPrescriptions(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.prescriptions;
    }
    final response = await dio.get(ApiEndpoints.patientPrescriptions);
    final list = response.data as List<dynamic>;
    return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LabReport>> getLabReports(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.labReports;
    }
    final response = await dio.get(ApiEndpoints.patientLabReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => LabReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ImagingReport>> getImagingReports(String healthId) async {
    if (isMock) {
      await _delay();
      return _mockDatasource.imagingReports;
    }
    final response = await dio.get(ApiEndpoints.patientImagingReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => ImagingReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    if (isMock) {
      await _delay();
      final index = _mockDatasource.appointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        final oldApp = _mockDatasource.appointments[index];
        _mockDatasource.appointments[index] = Appointment(
          id: oldApp.id,
          doctor: oldApp.doctor,
          date: oldApp.date,
          timeSlot: oldApp.timeSlot,
          hospital: oldApp.hospital,
          queueNumber: oldApp.queueNumber,
          status: 'Cancelled',
        );
      }
      return;
    }
    await dio.post(ApiEndpoints.cancelAppointment(appointmentId));
  }
}

