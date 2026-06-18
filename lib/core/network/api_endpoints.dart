class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String registerPatient = '/auth/register/patient';
  static const String registerDoctor = '/auth/register/doctor';

  // Patient
  static const String patientProfile = '/patient/profile';
  static const String patientDashboardSummary = '/patient/dashboard/summary';
  static const String patientAiSummary = '/patient/dashboard/ai-summary';
  
  // Doctor
  static const String doctorProfile = '/doctor/profile';
  static const String doctorDashboardSummary = '/doctor/dashboard/summary';
  static const String doctorQueue = '/doctor/queue';

  // Hospital
  static const String hospitalDashboardOverview = '/hospital/dashboard/overview';
  
  // Govt
  static const String govtDashboardOverview = '/govt/dashboard/national-overview';
}
