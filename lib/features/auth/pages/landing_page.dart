import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/application_provider.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 960;

    return Scaffold(
      backgroundColor: AppColors.sidebar,
      body: Column(
        children: [
          // Header / Top Navigation Bar
          _buildNavBar(context, isDesktop),
          
          // Main Content Area with Navigation Rail
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Rail
                NavigationRail(
                  backgroundColor: AppColors.sidebar.withOpacity(0.95),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  unselectedLabelTextStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                  selectedLabelTextStyle: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
                  selectedIconTheme: const IconThemeData(color: AppColors.primary),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_rounded),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.medical_services_rounded),
                      selectedIcon: Icon(Icons.medical_services_rounded),
                      label: Text('Services'),
                    ),
                  ],
                ),
                
                // Vertical Divider
                VerticalDivider(thickness: 1, width: 1, color: Colors.white.withOpacity(0.05)),
                
                // Main Scrollable Portal Contents
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 60 : 20,
                        vertical: 32,
                      ),
                      child: _selectedIndex == 0 ? _buildDashboardContent(context, isDesktop) : _buildServicesContent(context, isDesktop),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Urgent Advisory banner
        _buildUrgentBanner(),
        const SizedBox(height: 32),
        
        // Welcome & Portal Overview
        Text(
          'National Health Surveillance & Resource Portal',
          style: GoogleFonts.outfit(
            fontSize: isDesktop ? 36 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Official public dashboard of the Ministry of Health and Family Welfare, Government of Bangladesh.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 32),

        // Quick Stats grid
        _buildStatsGrid(isDesktop),
        const SizedBox(height: 40),

        // Main Layout split for desktop vs mobile
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildDiseaseOutbreakChart(context)),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _buildHospitalBedAvailability(context)),
            ],
          )
        else ...[
          _buildDiseaseOutbreakChart(context),
          const SizedBox(height: 32),
          _buildHospitalBedAvailability(context),
        ],

        const SizedBox(height: 40),
        // Information Cards Section
        _buildPublicServices(isDesktop),
        const SizedBox(height: 48),

        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildServicesContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Public Health Services & Applications',
          style: GoogleFonts.outfit(
            fontSize: isDesktop ? 36 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Apply for specialized roles, book appointments, or request administrative access.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 40),
        
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 220,
          ),
          children: [
            _buildServiceApplicationCard(
              title: 'Apply for Doctor Appointment',
              description: 'Schedule a visit with specialized national health doctors in available hospitals.',
              icon: Icons.calendar_month_rounded,
              color: AppColors.secondary,
              onTap: () {
                // Placeholder for appointment system
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please Sign In to book appointments.')));
              },
            ),
            _buildServiceApplicationCard(
              title: 'Apply for Doctor Role',
              description: 'Register yourself as a medical professional to get your verified Doctor dashboard.',
              icon: Icons.medical_information_rounded,
              color: Colors.blueAccent,
              onTap: () => _handleRoleApplication('DOCTOR', 'Doctor registration application'),
            ),
            _buildServiceApplicationCard(
              title: 'Apply for Hospital Admin',
              description: 'Register as an administrator to manage bed capacities, ICUs, and incoming patients.',
              icon: Icons.local_hospital_rounded,
              color: Colors.purpleAccent,
              onTap: () => _handleRoleApplication('HOSPITAL', 'Hospital Administrator application'),
            ),
            _buildServiceApplicationCard(
              title: 'Apply for Super Admin (Govt)',
              description: 'Request clearance for national-level Government oversight and approval authority.',
              icon: Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              onTap: () => _handleRoleApplication('GOVT', 'Government Super Admin application'),
            ),
          ],
        ),
        const SizedBox(height: 60),
        _buildFooter(),
      ],
    );
  }

  void _handleRoleApplication(String role, String notes) async {
    final usernameController = TextEditingController();
    
    final username = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Apply for $role Role', style: GoogleFonts.outfit(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please enter your username to submit the application.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty) {
                  Navigator.pop(context, usernameController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Submit Application', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (username == null || username.isEmpty) return;

    try {
      await ref.read(applicationServiceProvider).applyForRole(username, role, notes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application for $role submitted successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit application: $e')));
      }
    }
  }

  Widget _buildServiceApplicationCard({
    required String title, 
    required String description, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Apply Now',
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: color, size: 14),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, WidgetRef ref, bool isDesktop) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUDHEB',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'National Unified Health Ecosystem',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right options
          Row(
            children: [
              if (isDesktop) ...[
                _buildEmergencyBadge(Icons.phone_rounded, '333', 'National Health Help'),
                const SizedBox(width: 24),
                _buildEmergencyBadge(Icons.local_hospital_rounded, '999', 'Ambulance dispatch'),
                const SizedBox(width: 32),
              ],
              ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Sign In / Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBadge(IconData icon, String hotline, String desc) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Call $hotline',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              desc,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildUrgentBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH ALERT: High Dengue Vector Activity Detected',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MOHFW recommends clearing stagnant water around homes. Seek consultation immediately if experiencing rapid fever spikes.',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop) {
    final stats = [
      _StatData('Citizen Health Wallets', '84,203,149', Icons.wallet_rounded, AppColors.primary),
      _StatData('Registered Doctors', '53,291', Icons.medical_information_rounded, AppColors.secondary),
      _StatData('Integrated Facilities', '2,481', Icons.local_hospital_rounded, Colors.purple),
      _StatData('Vaccine Doses Issued', '194,541,202', Icons.vaccines_rounded, const Color(0xFF10B981)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 110,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: stat.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.value,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stat.label,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiseaseOutbreakChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disease Outbreak & Outpatient Trends',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'National monthly reports representing influenza and vector cases',
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: AppColors.primary, radius: 4),
                    const SizedBox(width: 6),
                    Text('Influenza', style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                    const SizedBox(width: 12),
                    const CircleAvatar(backgroundColor: AppColors.secondary, radius: 4),
                    const SizedBox(width: 6),
                    Text('Dengue', style: GoogleFonts.inter(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: OutbreakChartPainter(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul']
                .map((m) => Text(m, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalBedAvailability(BuildContext context) {
    final hospitals = [
      _HospitalStatus('Dhaka Medical College', 'Dhaka', 150, 2600),
      _HospitalStatus('Chittagong Medical College', 'Chattogram', 113, 1313),
      _HospitalStatus('Square Hospitals Ltd.', 'Dhaka', 80, 400),
      _HospitalStatus('Sylhet MAG Osmani Medical', 'Sylhet', 50, 900),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency ICU & Bed Tracker',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Real-time bed counts across integrated health networks',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hospitals.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 20),
            itemBuilder: (context, index) {
              final h = hospitals[index];
              final availPct = h.availableBeds / h.totalBeds;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${h.division} • ${h.totalBeds} Total Beds',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${h.availableBeds} Available',
                        style: GoogleFonts.outfit(
                          color: availPct > 0.15 ? Colors.greenAccent : Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 80,
                        height: 4,
                        child: LinearProgressIndicator(
                          value: availPct,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          color: availPct > 0.15 ? Colors.greenAccent : Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPublicServices(bool isDesktop) {
    final services = [
      _ServiceData('Verify Health ID', 'Check status and validation of your national Citizen Health profile wallet.', Icons.fingerprint_rounded),
      _ServiceData('Telehealth Directory', 'Find active clinicians, specialist queues, and consultation fees.', Icons.medical_services_outlined),
      _ServiceData('Vaccine Registration', 'Apply for Covid, Hep-B, and polio child booster dose cards.', Icons.shield_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Citizen e-Health Registries & Tools',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 160,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final s = services[index];
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.01),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s.icon, color: AppColors.secondary, size: 28),
                  const SizedBox(height: 16),
                  Text(
                    s.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.desc,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ministry of Health and Family Welfare, Bangladesh',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 NUDHEB Platform Ecosystem. Built for smart healthcare management.',
            style: GoogleFonts.inter(
              color: AppColors.textMuted.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.label, this.value, this.icon, this.color);
}

class _HospitalStatus {
  final String name;
  final String division;
  final int availableBeds;
  final int totalBeds;

  _HospitalStatus(this.name, this.division, this.availableBeds, this.totalBeds);
}

class _ServiceData {
  final String title;
  final String desc;
  final IconData icon;

  _ServiceData(this.title, this.desc, this.icon);
}

class OutbreakChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Draw horizontal grids
    for (double i = 0; i <= size.height; i += size.height / 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final fluPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final denguePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Chart mock data points
    final fluPoints = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.16, size.height * 0.6),
      Offset(size.width * 0.33, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.66, size.height * 0.35),
      Offset(size.width * 0.83, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    final denguePoints = [
      Offset(0, size.height * 0.95),
      Offset(size.width * 0.16, size.height * 0.85),
      Offset(size.width * 0.33, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.66, size.height * 0.15),
      Offset(size.width * 0.83, size.height * 0.25),
      Offset(size.width, size.height * 0.45),
    ];

    final fluPath = Path()..moveTo(fluPoints.first.dx, fluPoints.first.dy);
    for (var p in fluPoints) {
      fluPath.lineTo(p.dx, p.dy);
    }

    final denguePath = Path()..moveTo(denguePoints.first.dx, denguePoints.first.dy);
    for (var p in denguePoints) {
      denguePath.lineTo(p.dx, p.dy);
    }

    // Draw lines
    canvas.drawPath(fluPath, fluPaint);
    canvas.drawPath(denguePath, denguePaint);

    // Draw dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (var p in fluPoints) {
      canvas.drawCircle(p, 4, dotPaint..color = AppColors.primary);
    }
    for (var p in denguePoints) {
      canvas.drawCircle(p, 4, dotPaint..color = AppColors.secondary);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavBarLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavBarLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

