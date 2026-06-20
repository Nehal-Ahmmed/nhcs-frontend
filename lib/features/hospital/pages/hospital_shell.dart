import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sidebar.dart';
import '../presentation/providers/hospital_providers.dart';
import 'command_center_page.dart';
import 'reception_queue_page.dart';
import 'staff_management_page.dart';
import 'laboratory_page.dart';
import 'bed_management_page.dart';
import 'pharmacy_page.dart';

class HospitalShell extends ConsumerWidget {
  const HospitalShell({super.key});

  static const List<Widget> _pages = [
    CommandCenterPage(),
    ReceptionQueuePage(),
    StaffManagementPage(),
    LaboratoryPage(),
    BedManagementPage(),
    PharmacyPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(hospitalNavigationProvider);

    return Scaffold(
      body: Row(
        children: [
          HospitalSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (i) => ref.read(hospitalNavigationProvider.notifier).state = i,
          ),
          Expanded(child: _pages[selectedIndex]),
        ],
      ),
    );
  }
}
