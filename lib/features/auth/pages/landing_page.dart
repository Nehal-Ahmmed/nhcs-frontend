import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient subtle highlights instead of heavy blobs for a cleaner look
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 300,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Blur layer to soften the circles
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          
          // Main Content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header / Navigation Bar
                  _buildNavBar(context, ref, isDesktop),

                  // Hero Section
                  _buildHeroSection(context, isDesktop, size),

                  // Statistics Section
                  _buildStatsSection(context, isDesktop),

                  // Core Features Section
                  _buildFeaturesSection(context, isDesktop),

                  // Call to Action Section
                  _buildCTASection(context),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context, WidgetRef ref, bool isDesktop) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
          // Logo & Name
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
              Text(
                'NUDHEB',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          // Navigation Links
          if (isDesktop)
            Row(
              children: [
                _NavBarLink(title: 'Home', onTap: () => context.go('/')),
                const SizedBox(width: 24),
                _NavBarLink(title: 'About', onTap: () {}),
                const SizedBox(width: 24),
                _NavBarLink(title: 'Contact', onTap: () {}),
                const SizedBox(width: 24),
                _NavBarLink(title: 'Search Doctors', onTap: () {}),
              ],
            ),

          // Action Button
          ElevatedButton(
            onPressed: () {
              if (isAuthenticated) {
                switch (authState.role) {
                  case AppConstants.rolePatient: context.go('/user'); break;
                  case AppConstants.roleDoctor: context.go('/doctor'); break;
                  case AppConstants.roleHospital: context.go('/authority'); break;
                  case AppConstants.roleGovt: context.go('/government'); break;
                  default: context.go('/role');
                }
              } else {
                context.go('/role');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
            ),
            child: Text(
              isAuthenticated ? 'Dashboard' : 'Sign In / Register',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop, Size size) {
    final content = Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text(
            '🇧🇩 Digital Bangladesh Health Initiative',
            style: GoogleFonts.inter(
              color: AppColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'National Unified Digital\nHealthcare Ecosystem',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: isDesktop ? 54 : 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connecting Citizens, Medical Professionals, Hospital Networks, and Policy Makers into one secure, unified digital infrastructure.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: isDesktop ? 18 : 14,
            color: AppColors.textMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment:
              isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/role'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ).copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        'Get Started / Access Portal',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final heroImage = Center(
      child: Container(
        height: isDesktop ? 450 : 350,
        width: isDesktop ? double.infinity : 350,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),
              Positioned(
                top: 40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.monitor_heart_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Live Analytics', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text('National Network', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('System Secure', style: GoogleFonts.inter(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shield_rounded, color: AppColors.secondary.withOpacity(0.8), size: 64),
                                  const SizedBox(height: 16),
                                  Text('100% Encrypted', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('NUDHEB Shield', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.8), AppColors.secondary.withOpacity(0.8)]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('4,200+', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                        Text('Hospitals Connected', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('10M+', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                        Text('Citizen Records Secured', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 40,
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 60),
                Expanded(child: heroImage),
              ],
            )
          : Column(
              children: [
                content,
                const SizedBox(height: 48),
                heroImage,
              ],
            ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDesktop) {
    final stats = [
      _StatsItem(
        label: 'Citizen Health Wallets',
        value: '165M+',
        icon: Icons.people_rounded,
        color: AppColors.primary,
      ),
      _StatsItem(
        label: 'Registered Clinicians',
        value: '50K+',
        icon: Icons.medical_services_rounded,
        color: AppColors.secondary,
      ),
      _StatsItem(
        label: 'Integrated Facilities',
        value: '2.5K+',
        icon: Icons.local_hospital_rounded,
        color: Colors.purple,
      ),
      _StatsItem(
        label: 'Surveillance Analytics',
        value: 'Real-time',
        icon: Icons.analytics_rounded,
        color: Colors.orange,
      ),
    ];

    return Container(
      color: Colors.black.withOpacity(0.15),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 60,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: stats
                  .map((stat) => Expanded(child: _buildStatCard(stat)))
                  .toList(),
            );
          } else {
            return Column(
              children: stats.map((stat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildStatCard(stat),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(_StatsItem stat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(stat.icon, color: stat.color, size: 36),
          const SizedBox(height: 16),
          Text(
            stat.value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    final features = [
      _FeatureItem(
        title: 'Unified Health ID',
        desc:
            'A lifetime digital identity for every citizen, consolidates your full history of clinical visits, labs, prescriptions, and reports.',
        icon: Icons.fingerprint_rounded,
      ),
      _FeatureItem(
        title: 'Smart Clinical Workspace',
        desc:
            'AI-guided diagnostics tool for registered doctors to write smart prescriptions, view history, and coordinate care referrals.',
        icon: Icons.add_moderator_rounded,
      ),
      _FeatureItem(
        title: 'Command Center & Pharmacy',
        desc:
            'Hospital management tools including electronic queues, automated inventory control, and direct-to-pharmacy prescription delivery.',
        icon: Icons.dashboard_customize_rounded,
      ),
      _FeatureItem(
        title: 'National Surveillance',
        desc:
            'Enables the Ministry of Health to trace epidemic vectors, manage national resources, and dispatch automated warnings.',
        icon: Icons.security_update_good_rounded,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Integrated Ecosystem Pillars',
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Four major segments operating in a secure, unified decentralized blockchain network.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              childAspectRatio: isDesktop ? 1.8 : 1.4,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature.icon,
                        color: AppColors.secondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      feature.title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          feature.desc,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
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

  Widget _buildCTASection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Join the National Health Network?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your digital health identity today or log in to your portal.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/role'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: Text(
              'Access Portal',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.health_and_safety,
                color: AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'NUDHEB Ecosystem Platform',
                style: GoogleFonts.outfit(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026 Ministry of Health and Family Welfare, Government of the People\'s Republic of Bangladesh',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatsItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _FeatureItem {
  final String title;
  final String desc;
  final IconData icon;

  _FeatureItem({
    required this.title,
    required this.desc,
    required this.icon,
  });
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const double gridSpacing = 30.0;

    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
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

