import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/appointment.dart';
import '../models/dashboard_summary.dart';
import '../models/health_event.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';

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

  PatientRepositoryImpl(this.dio, [bool? isMock]);

  @override
  Future<DashboardSummary> getDashboardSummary(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientDashboardSummary);
    return DashboardSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AiHealthSummary> getAiHealthSummary(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientAiSummary);
    return AiHealthSummary.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> getPatientProfile(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientProfile);
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PatientProfile> updatePatientProfile(String healthId, PatientProfile profile) async {
    final response = await dio.put(
      ApiEndpoints.patientProfile,
      data: profile.toJson(),
    );
    return PatientProfile.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<HealthEvent>> getHealthEvents(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientTimeline);
    final list = response.data as List<dynamic>;
    return list.map((e) => HealthEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DoctorSpecialist>> getAvailableDoctors() async {
    final response = await dio.get(ApiEndpoints.doctorsList);
    final list = response.data as List<dynamic>;
    return list.map((e) => DoctorSpecialist.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(String doctorId, DateTime date) async {
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
    final response = await dio.get(ApiEndpoints.patientAppointments);
    final list = response.data as List<dynamic>;
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Prescription>> getPrescriptions(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientPrescriptions);
    final list = response.data as List<dynamic>;
    return list.map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LabReport>> getLabReports(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientLabReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => LabReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ImagingReport>> getImagingReports(String healthId) async {
    final response = await dio.get(ApiEndpoints.patientImagingReports);
    final list = response.data as List<dynamic>;
    return list.map((e) => ImagingReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await dio.post(ApiEndpoints.cancelAppointment(appointmentId));
  }
}

