class AppConstants {
  static const String appName = 'NUDHEB';
  static const String appVersion = '1.0.0';

  // Network
  // Note: For Android Emulator use 10.0.2.2. For iOS Simulator or Web use localhost
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080/api/v1');
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';

  // Roles
  static const String rolePatient = 'PATIENT';
  static const String roleDoctor = 'DOCTOR';
  static const String roleHospital = 'HOSPITAL';
  static const String roleGovt = 'GOVT';
}
