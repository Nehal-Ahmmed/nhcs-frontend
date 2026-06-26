class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';

  // Patient
  static const String patientProfile = '/patients/me';
  static const String patientDashboardSummary = '/patients/dashboard/summary';
  static const String patientAiSummary = '/patients/dashboard/ai-summary';
  static const String patientTimeline = '/patients/me/timeline';
  static const String patientAppointments = '/patients/me/appointments';
  static const String patientPrescriptions = '/patients/me/prescriptions';
  static const String patientLabReports = '/patients/me/lab-reports';
  static const String patientImagingReports = '/patients/me/imaging-reports';
  static String cancelAppointment(String id) => '/patients/me/appointments/$id/cancel';
  
  // Doctor
  static const String doctorProfile = '/doctors/me';
  static const String doctorDashboardSummary = '/doctor/dashboard/summary';
  static const String doctorQueue = '/doctor/queue';
  static const String doctorsList = '/doctors';
  static String doctorSlots(String doctorId) => '/doctors/$doctorId/slots';

  // Hospital
  static const String hospitalDashboardOverview = '/hospital/dashboard/overview';
  
  // Govt
  static const String govtDashboardOverview = '/govt/dashboard/national-overview';
  // Applications
  static const String applyRole = '/applications';
  static const String pendingApplications = '/applications/pending';
  static String approveApplication(int id) => '/applications/$id/approve';
  static String rejectApplication(int id) => '/applications/$id/reject';
}
