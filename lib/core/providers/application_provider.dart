import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../network/api_endpoints.dart';
import 'dio_provider.dart';

class RoleApplication {
  final int id;
  final String requestedRole;
  final String status;
  final String applicationDate;
  final String? notes;

  RoleApplication({
    required this.id,
    required this.requestedRole,
    required this.status,
    required this.applicationDate,
    this.notes,
  });

  factory RoleApplication.fromJson(Map<String, dynamic> json) {
    return RoleApplication(
      id: json['id'],
      requestedRole: json['requestedRole'],
      status: json['status'],
      applicationDate: json['applicationDate'],
      notes: json['notes'],
    );
  }
}

class PendingApplicationsNotifier
    extends StateNotifier<AsyncValue<List<RoleApplication>>> {
  final Ref ref;

  PendingApplicationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchPendingApplications();
  }

  Future<void> fetchPendingApplications() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.pendingApplications);
      final List<dynamic> data = response.data;
      final apps = data.map((json) => RoleApplication.fromJson(json)).toList();
      state = AsyncValue.data(apps);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveApplication(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put(ApiEndpoints.approveApplication(id));
      await fetchPendingApplications();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectApplication(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put(ApiEndpoints.rejectApplication(id));
      await fetchPendingApplications();
    } catch (e) {
      rethrow;
    }
  }
}

final pendingApplicationsProvider =
    StateNotifierProvider<
      PendingApplicationsNotifier,
      AsyncValue<List<RoleApplication>>
    >((ref) {
      return PendingApplicationsNotifier(ref);
    });

final applicationServiceProvider = Provider((ref) => ApplicationService(ref));

class ApplicationService {
  final Ref ref;
  ApplicationService(this.ref);

  Future<void> applyForRole(String username, String role, String notes) async {
    final dio = ref.read(dioProvider);
    await dio.post(
      ApiEndpoints.applyRole,
      data: {'username': username, 'requestedRole': role, 'notes': notes},
    );
  }
}
