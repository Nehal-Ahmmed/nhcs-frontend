import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sidebar.dart';
import '../presentation/providers/govt_providers.dart';
import 'govt_dashboard_page.dart';
import 'govt_registries_page.dart';
import 'govt_diseases_page.dart';
import 'govt_resources_page.dart';
import 'govt_compliance_page.dart';

class GovtShell extends ConsumerWidget {
  const GovtShell({super.key});

  static const List<Widget> _pages = [
    GovtDashboardPage(),
    GovtRegistriesPage(),
    GovtDiseasesPage(),
    GovtResourcesPage(),
    GovtCompliancePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(govtNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          GovtSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => ref.read(govtNavigationProvider.notifier).state = i,
          ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
