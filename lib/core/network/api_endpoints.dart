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
  
  // Doctor
  static const String doctorProfile = '/doctors/me';
  static const String doctorDashboardSummary = '/doctor/dashboard/summary';
  static const String doctorQueue = '/doctor/queue';

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
