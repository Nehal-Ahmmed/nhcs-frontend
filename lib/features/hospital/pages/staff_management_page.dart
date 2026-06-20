import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/staff_member.dart';
import '../presentation/providers/hospital_providers.dart';

class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addStaffMember(String name, String role, String dept, String shift) {
    final staffList = ref.read(staffRosterProvider);
    final id = 'S-${(staffList.length + 1).toString().padLeft(3, '0')}';
    final newStaff = StaffMember(
      id: id,
      name: name,
      role: role,
      dept: dept,
      status: 'Active',
      shifts: {'Monday': shift},
    );
    ref.read(staffRosterProvider.notifier).addStaffMember(newStaff);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $name to Hospital Directory.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _approveDoctor(String id, String name) {
    ref.read(doctorVerificationsProvider.notifier).verifyDoctor(id, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Approved $name! Added to Hospital Staff Directory.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectDoctor(String id) {
    ref.read(doctorVerificationsProvider.notifier).verifyDoctor(id, false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application rejected.'), backgroundColor: AppColors.danger),
    );
  }

  void _editShiftDialog(StaffMember staff, String day) {
    final shiftCont = TextEditingController(text: staff.shifts[day] ?? 'Off');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Duty Shift for ${staff.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Day: $day', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ['Off', 'OPD', 'Ward', 'Emergency', 'Night'].contains(shiftCont.text) ? shiftCont.text : 'OPD',
                decoration: const InputDecoration(labelText: 'Shift Designation'),
                onChanged: (val) {
                  if (val != null) {
                    shiftCont.text = val;
                  }
                },
                items: ['Off', 'OPD', 'Ward', 'Emergency', 'Night']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ref.read(staffRosterProvider.notifier).updateShift(staff.id, day, shiftCont.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated shift for ${staff.name} on $day to ${shiftCont.text}')),
                );
              },
              child: const Text('Save Shift'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectoryTab(),
                _buildRosterTab(),
                _buildApplicationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff & Workforce Management',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage clinical rosters, staff directory list, and verify doctor affiliations.',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddStaffDialog(),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Staff Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Staff Directory'),
          Tab(text: 'Duty Roster Planner'),
          Tab(text: 'Verification Queue'),
        ],
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildDirectoryTab() {
    final staffList = ref.watch(staffRosterProvider);
    final query = _searchController.text.toLowerCase();
    
    final filtered = staffList.where((staff) {
      final matchesQuery = staff.name.toLowerCase().contains(query) || staff.dept.toLowerCase().contains(query);
      final matchesRole = _selectedRoleFilter == 'All' || staff.role == _selectedRoleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            // Filter Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search staff by name or department...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedRoleFilter,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRoleFilter = val);
                      }
                    },
                    items: ['All', 'Doctor', 'Nurse', 'Technician', 'Pharmacist']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Table
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('No staff matches filter criteria', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Department')),
                            DataColumn(label: Text('Shift (Mon)')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: filtered.map((staff) {
                            return DataRow(cells: [
                              DataCell(Text(staff.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                              DataCell(Text(staff.role)),
                              DataCell(Text(staff.dept)),
                              DataCell(Text(staff.shifts['Monday'] ?? 'Off')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    staff.status,
                                    style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterTab() {
    final List<String> days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final staffList = ref.watch(staffRosterProvider);
    final clinicalStaff = staffList.where((s) => s.role == 'Doctor' || s.role == 'Nurse').toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Staff Member')),
                ...days.map((d) => DataColumn(label: Text(d))),
              ],
              rows: clinicalStaff.map((staff) {
                return DataRow(
                  cells: [
                    DataCell(Text(staff.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                    ...days.map((day) {
                      final shift = staff.shifts[day] ?? 'Off';
                      Color color = AppColors.textSecondary;
                      Color bg = AppColors.background;
                      if (shift == 'Emergency') {
                        color = AppColors.danger;
                        bg = AppColors.dangerLight;
                      } else if (shift == 'OPD') {
                        color = AppColors.primary;
                        bg = AppColors.primaryLight;
                      } else if (shift == 'Ward') {
                        color = AppColors.secondary;
                        bg = AppColors.secondaryLight;
                      } else if (shift == 'Night') {
                        color = Colors.indigo;
                        bg = Colors.indigo.shade50;
                      }

                      return DataCell(
                        InkWell(
                          onTap: () => _editShiftDialog(staff, day),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bg.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withOpacity(0.15)),
                            ),
                            child: Text(
                              shift,
                              style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsTab() {
    final pendingDoctors = ref.watch(doctorVerificationsProvider).where((r) => r.status == 'Pending').toList();

    return pendingDoctors.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 54, color: AppColors.success),
                const SizedBox(height: 16),
                Text(
                  'All Applications Reviewed',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'No pending doctor affiliations at this time.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: pendingDoctors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = pendingDoctors[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accentLight,
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('BMDC Registration: ${doc.bmdcNo}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Specialization: ${doc.specialization}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Submitted Date: ${doc.date}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showCredentialsDialog(doc);
                                },
                                icon: const Icon(Icons.description_rounded, size: 16),
                                label: const Text('View Credentials'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _rejectDoctor(doc.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _approveDoctor(doc.id, doc.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Approve Affiliation'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
  }

  void _showCredentialsDialog(DoctorVerificationRequest doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${doc.name} - Credentials Summary', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCredentialItem('Medical Board License', 'BMDC Verification Status: VALIDATED (National Database Link)'),
              _buildCredentialItem('Degree Certificate', 'MBBS, MD - Dhaka Medical College (Verified)'),
              _buildCredentialItem('NID Match', 'Verified with Bangladesh Election Commission databases'),
              _buildCredentialItem('Specialist Qualification', 'Fellowship of College of Physicians and Surgeons (FCPS)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  Widget _buildCredentialItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(desc, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog() {
    final nameCont = TextEditingController();
    String role = 'Doctor';
    String dept = 'Cardiology';
    String shift = 'Morning';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New Staff Member', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCont,
                    decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g., Dr. Amina Islam'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    onChanged: (val) => setDialogState(() => role = val!),
                    items: ['Doctor', 'Nurse', 'Technician', 'Pharmacist']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: dept,
                    decoration: const InputDecoration(labelText: 'Department'),
                    onChanged: (val) => setDialogState(() => dept = val!),
                    items: ['Cardiology', 'Emergency', 'Pediatrics', 'Laboratory', 'Pharmacy', 'General Ward']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: shift,
                    decoration: const InputDecoration(labelText: 'Shift'),
                    onChanged: (val) => setDialogState(() => shift = val!),
                    items: ['Morning', 'Evening', 'Night']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCont.text.isNotEmpty) {
                      _addStaffMember(nameCont.text, role, dept, shift);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Staff'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
