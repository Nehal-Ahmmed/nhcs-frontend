import 'package:flutter_riverpod/legacy.dart';

class AppNotification {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final bool isRead;
  final String type; // 'info', 'warning', 'danger', 'success'
  final String actionRoute; // e.g. '/user', '/doctor', '/authority', '/government'
  final int actionTab; // Target sidebar index tab

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    required this.actionRoute,
    required this.actionTab,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    bool? isRead,
    String? type,
    String? actionRoute,
    int? actionTab,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actionRoute: actionRoute ?? this.actionRoute,
      actionTab: actionTab ?? this.actionTab,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final String role;

  NotificationsNotifier(this.role) : super([]) {
    _loadInitialNotifications();
  }

  void _loadInitialNotifications() {
    if (role == 'PATIENT') {
      state = [
        const AppNotification(
          id: 'n1',
          title: 'New Prescription Uploaded',
          description: 'Dr. Ahmed Khan uploaded a new prescription for your cardiology evaluation.',
          timestamp: '1 hour ago',
          type: 'info',
          actionRoute: '/user',
          actionTab: 4, // Medical Vault tab
        ),
        const AppNotification(
          id: 'n2',
          title: 'Upcoming Consultation Tomorrow',
          description: 'Your slot with Dr. Subrata Sen is confirmed for tomorrow at 10:00 AM.',
          timestamp: '3 hours ago',
          type: 'warning',
          actionRoute: '/user',
          actionTab: 3, // Appointments list
        ),
      ];
    } else if (role == 'DOCTOR') {
      state = [
        const AppNotification(
          id: 'nd1',
          title: 'Patient Checked In',
          description: 'Fatema Zohra checked into Emergency Ward and awaits medical consult.',
          timestamp: '10 mins ago',
          type: 'danger',
          actionRoute: '/doctor',
          actionTab: 0, // Dashboard consult queue
        ),
        const AppNotification(
          id: 'nd2',
          title: 'Laboratory Results Published',
          description: 'Test results for Rahim Islam (CBC Panel) are verified and published.',
          timestamp: '1 hour ago',
          type: 'success',
          actionRoute: '/doctor',
          actionTab: 2, // Report review
        ),
      ];
    } else if (role == 'HOSPITAL') {
      state = [
        const AppNotification(
          id: 'nh1',
          title: 'Critical Bed Capacity Alert',
          description: 'ICU ward occupancy has reached 94% (15/16 beds occupied).',
          timestamp: '5 mins ago',
          type: 'danger',
          actionRoute: '/authority',
          actionTab: 4, // Bed management page
        ),
        const AppNotification(
          id: 'nh2',
          title: 'Low stock: Paracetamol',
          description: 'Paracetamol 500mg tablets stock count fell below 1,000 threshold limits.',
          timestamp: '1 hour ago',
          type: 'warning',
          actionRoute: '/authority',
          actionTab: 5, // Pharmacy inventory
        ),
      ];
    } else if (role == 'GOVT') {
      state = [
        const AppNotification(
          id: 'ng1',
          title: 'Dengue Case Outbreak Warning',
          description: 'Weekly surveillance flags Dengue spike threshold limits exceeded in Dhaka North.',
          timestamp: '2 hours ago',
          type: 'danger',
          actionRoute: '/government',
          actionTab: 2, // Disease intelligence page
        ),
        const AppNotification(
          id: 'ng2',
          title: 'Pending Compliance Review',
          description: 'Khulna District Hospital compliance score updated. Review licensing status.',
          timestamp: '1 day ago',
          type: 'warning',
          actionRoute: '/government',
          actionTab: 4, // Compliance center page
        ),
      ];
    }
  }

  void markAsRead(String notificationId) {
    state = state.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }
}

final patientNotificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier('PATIENT');
});

final doctorNotificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier('DOCTOR');
});

final hospitalNotificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier('HOSPITAL');
});

final govtNotificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier('GOVT');
});
