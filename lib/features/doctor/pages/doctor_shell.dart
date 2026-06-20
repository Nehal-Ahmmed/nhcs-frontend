import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sidebar.dart';
import '../presentation/providers/doctor_providers.dart';
import 'doctor_dashboard_page.dart';
import 'clinical_workspace_page.dart';
import 'report_review_page.dart';
import 'doctor_schedule_page.dart';
import 'doctor_profile_page.dart';

class DoctorShell extends ConsumerWidget {
  const DoctorShell({super.key});

  static const List<Widget> _pages = [
    DoctorDashboardPage(),
    ClinicalWorkspacePage(),
    ReportReviewPage(),
    DoctorSchedulePage(),
    DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(doctorNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          DoctorSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => ref.read(doctorNavigationProvider.notifier).state = i,
          ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
