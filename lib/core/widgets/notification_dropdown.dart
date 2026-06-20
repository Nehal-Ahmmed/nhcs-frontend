import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/notifications_provider.dart';

class NotificationDropdown extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(String) onMarkRead;
  final Function() onMarkAllRead;
  final Function(int) onNavigate;

  const NotificationDropdown({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      position: PopupMenuPosition.under,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 20),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$unreadCount',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'Notifications',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 340),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      onMarkAllRead();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Mark all as read', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          if (notifications.isEmpty)
            PopupMenuItem<String>(
              enabled: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No new alerts.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                ),
              ),
            )
          else
            ...notifications.map((n) {
              Color statusColor = AppColors.info;
              Color bgLight = AppColors.infoLight;
              if (n.type == 'danger') {
                statusColor = AppColors.danger;
                bgLight = AppColors.dangerLight;
              } else if (n.type == 'warning') {
                statusColor = AppColors.warning;
                bgLight = AppColors.warningLight;
              } else if (n.type == 'success') {
                statusColor = AppColors.success;
                bgLight = AppColors.successLight;
              }

              return PopupMenuItem<String>(
                value: n.id,
                onTap: () {
                  onMarkRead(n.id);
                  onNavigate(n.actionTab);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: n.isRead ? Colors.transparent : statusColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: bgLight, shape: BoxShape.circle),
                        child: Icon(
                          n.type == 'danger'
                              ? Icons.warning_amber_rounded
                              : (n.type == 'warning' ? Icons.notifications_active_rounded : Icons.info_outline_rounded),
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.description,
                              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(n.timestamp, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ];
      },
    );
  }
}
