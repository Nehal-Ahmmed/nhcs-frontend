import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/notification_dropdown.dart';
import '../../../core/providers/notifications_provider.dart';
import '../presentation/providers/govt_providers.dart';

class GovtDashboardPage extends ConsumerStatefulWidget {
  const GovtDashboardPage({super.key});

  @override
  ConsumerState<GovtDashboardPage> createState() => _GovtDashboardPageState();
}

class _GovtDashboardPageState extends ConsumerState<GovtDashboardPage> {
  bool _isRefreshing = false;
  late DateTime _lastUpdated;

  @override
  void initState() {
    super.initState();
    _lastUpdated = DateTime.now();
  }

  void _simulateRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(govtDashboardStatsProvider.notifier).refresh();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _lastUpdated = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(govtDashboardStatsProvider);
    final notifications = ref.watch(govtNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(notifications),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(stats),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildSurveillanceCard(stats),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildAlertsCard(stats),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<AppNotification> notifications) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MoHFW National Telemetry Console',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unified National Health Ecosystem connected • Live Data',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Last Updated: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _simulateRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Sync National Database',
          ),
          const SizedBox(width: 16),
          NotificationDropdown(
            notifications: notifications,
            onMarkRead: (id) => ref.read(govtNotificationsProvider.notifier).markAsRead(id),
            onMarkAllRead: () => ref.read(govtNotificationsProvider.notifier).markAllAsRead(),
            onNavigate: (tabIndex) {
              ref.read(govtNavigationProvider.notifier).state = tabIndex;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(var stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Registered Citizens',
              value: stats.totalRegisteredCitizens.toString(),
              subvalue: 'Health Identity Directory',
              icon: Icons.people_rounded,
              color: AppColors.primary,
              trend: 'Live Database Sync',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Active Practitioners',
              value: stats.totalRegisteredDoctors.toString(),
              subvalue: 'BMDC Authenticated Board',
              icon: Icons.badge_rounded,
              color: AppColors.secondary,
              trend: 'All licenses monitored',
              trendColor: AppColors.textSecondary,
            ),
            _buildStatCard(
              title: 'Licensed Facilities',
              value: stats.totalLicensedHospitals.toString(),
              subvalue: 'National Hospital Register',
              icon: Icons.local_hospital_rounded,
              color: AppColors.accent,
              trend: 'Bed Capacity: ${stats.nationalBedOccupancyRate}% Occupancy',
              trendColor: AppColors.warning,
            ),
            _buildStatCard(
              title: 'Critical Outbreaks',
              value: stats.activeDiseaseOutbreaks.toString(),
              subvalue: 'Active Survelliance Alert',
              icon: Icons.bug_report_rounded,
              color: AppColors.danger,
              trend: 'Surveillance active',
              trendColor: AppColors.danger,
              pulse: stats.activeDiseaseOutbreaks > 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subvalue,
    required IconData icon,
    required Color color,
    required String trend,
    required Color trendColor,
    bool pulse = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          if (subvalue != null) ...[
            const SizedBox(height: 2),
            Text(
              subvalue,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              if (pulse) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: trendColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                trend,
                style: GoogleFonts.inter(color: trendColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurveillanceCard(var stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Outbreak & Disease Surveillance',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton.icon(
                onPressed: () => ref.read(govtNavigationProvider.notifier).state = 2, // Go to disease surveillance
                icon: const Icon(Icons.analytics_rounded, size: 16, color: AppColors.primary),
                label: Text('Surveillance Board', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.8))),
                ),
                children: [
                  _tableHeader('Disease'),
                  _tableHeader('Active Cases'),
                  _tableHeader('Risk Level'),
                  _tableHeader('Trend'),
                  _tableHeader('Affected Division'),
                ],
              ),
              ...stats.outbreaks.map<TableRow>((o) {
                Color riskColor = AppColors.success;
                Color riskBg = AppColors.successLight;
                if (o.riskLevel == 'High') {
                  riskColor = AppColors.danger;
                  riskBg = AppColors.dangerLight;
                } else if (o.riskLevel == 'Moderate') {
                  riskColor = AppColors.warning;
                  riskBg = AppColors.warningLight;
                }

                IconData trendIcon = Icons.trending_flat_rounded;
                Color trendColor = AppColors.textMuted;
                if (o.trend == 'Rising') {
                  trendIcon = Icons.trending_up_rounded;
                  trendColor = AppColors.danger;
                } else if (o.trend == 'Falling') {
                  trendIcon = Icons.trending_down_rounded;
                  trendColor = AppColors.success;
                }

                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.3))),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(o.diseaseName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('${o.activeCases} (+${o.weeklyNewCases} w/k)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: riskBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(o.riskLevel, style: GoogleFonts.inter(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(trendIcon, color: trendColor, size: 16),
                          const SizedBox(width: 4),
                          Text(o.trend, style: GoogleFonts.inter(color: trendColor, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(o.affectedAreas, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget _buildAlertsCard(var stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'National Health Alerts',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (stats.alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('No active health alerts declared.', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = stats.alerts[index];
                Color accentColor = AppColors.info;
                Color bgColor = AppColors.infoLight;
                if (alert.type == 'danger') {
                  accentColor = AppColors.danger;
                  bgColor = AppColors.dangerLight;
                } else if (alert.type == 'warning') {
                  accentColor = AppColors.warning;
                  bgColor = AppColors.warningLight;
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        alert.type == 'danger' ? Icons.error_rounded : (alert.type == 'warning' ? Icons.warning_rounded : Icons.info_rounded),
                        color: accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.title, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(alert.description, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Division: ${alert.division}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                Text(alert.timeAgo, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
