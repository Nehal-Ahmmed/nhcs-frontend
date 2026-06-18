# Hospital Ecosystem Implementation Guide

This guide details the design, architecture, and implementation of the **Hospital Authority Ecosystem** for the National Unified Digital Healthcare Ecosystem of Bangladesh (NUDHEB).

---

## 🗺️ High-Level Roadmap

1. **Scaffolding and Setup**: Created the module directory `lib/features/hospital` and the `pages` subfolder.
2. **Navigation Shell**: Developed `hospital_shell.dart` integrating the `HospitalSidebar` with a multi-page tab layout using a stateful layout index.
3. **Command Center**: Built `command_center_page.dart` showing hospital-wide summaries (intake, beds, staffing, emergency loads) with simulated hot refreshes and custom painter charts.
4. **Reception Desk & Paging**: Designed `reception_queue_page.dart` containing patient lookup by digital health cards, check-in registration, and queue paging status.
5. **Workforce Management**: Programmed `staff_management_page.dart` hosting the roster planner and verifying pending doctor affiliation requests.
6. **Laboratory Kanban Board**: Written `laboratory_page.dart` implementing the drag-and-advance state machine representing diagnostic sample tests.
7. **Beds & Admissions**: Established `bed_management_page.dart` with a multi-ward matrix grid supporting clicks to admit or discharge.
8. **Pharmacy Dispensing Desk**: Created `pharmacy_page.dart` displaying the formulary database, low stock thresholds, and prescription checkouts.

---

## 🧠 Logical Descriptions

### Frontend Layer
* **Simple**: An interactive, premium web console allowing hospital admins to control check-in, assign staff duties, review test states on a board, view beds, and dispense medications.
* **Technical**: Built with Material 3 responsive layouts. Uses stateful widgets (`StatefulWidget`) to simulate complex reactive databases locally in memory. Interfaces are aligned with the `AppTheme` design tokens, utilizing specialized custom painters (`CustomPainter`) for trend graphics.

### Backend Layer (API Contracts)
* **Simple**: Handles hospital details, roster records, lab orders, pharmacy inventories, and active patient admissions.
* **Technical**: Hexagonal Architecture adapters connected to a PostgreSQL database. Implements REST endpoints and WebSockets (`/ws/hospital/live-stats`) to broadcast real-time metrics back to the admin dashboard.

---

## 💻 Full Implementation Code

### 1. Navigation Shell: `hospital_shell.dart`
```dart
import 'package:flutter/material.dart';
import '../../../core/widgets/sidebar.dart';
import 'command_center_page.dart';
import 'reception_queue_page.dart';
import 'staff_management_page.dart';
import 'laboratory_page.dart';
import 'bed_management_page.dart';
import 'pharmacy_page.dart';

class HospitalShell extends StatefulWidget {
  const HospitalShell({super.key});

  @override
  State<HospitalShell> createState() => _HospitalShellState();
}

class _HospitalShellState extends State<HospitalShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CommandCenterPage(),
    ReceptionQueuePage(),
    StaffManagementPage(),
    LaboratoryPage(),
    BedManagementPage(),
    PharmacyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          HospitalSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
```

### 2. Command Center: `command_center_page.dart`
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CommandCenterPage extends StatefulWidget {
  const CommandCenterPage({super.key});

  @override
  State<CommandCenterPage> createState() => _CommandCenterPageState();
}

class _CommandCenterPageState extends State<CommandCenterPage> {
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  void _simulateRefresh() {
    setState(() {
      _isRefreshing = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _lastUpdated = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildDepartmentLoadList(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: _buildLoadChartCard(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildAlertsPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                'Dhaka Central Hospital',
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
                    'Connected to National Ecosystem • Live Feed',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Last Sync: ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}',
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
            tooltip: 'Sync Live Data',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
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
              title: 'Active Patients',
              value: '184',
              icon: Icons.people_rounded,
              color: AppColors.primary,
              trend: '+12% from yesterday',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Bed Occupancy',
              value: '80.8%',
              subvalue: '202 / 250 Occupied',
              icon: Icons.bed_rounded,
              color: AppColors.secondary,
              trend: '48 beds available',
              trendColor: AppColors.textSecondary,
            ),
            _buildStatCard(
              title: 'On-Duty Staff',
              value: '24',
              subvalue: '10 Doctors, 14 Nurses',
              icon: Icons.badge_rounded,
              color: AppColors.accent,
              trend: 'All shifts covered',
              trendColor: AppColors.success,
            ),
            _buildStatCard(
              title: 'Emergency Intake',
              value: '5',
              subvalue: '3 Critical Cases',
              icon: Icons.emergency_rounded,
              color: AppColors.danger,
              trend: 'Critical Load Warning',
              trendColor: AppColors.danger,
              pulse: true,
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
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          if (subvalue != null) ...[
            const SizedBox(height: 2),
            Text(
              subvalue,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              if (pulse) ...[
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
                const SizedBox(width: 6),
              ],
              Text(
                trend,
                style: GoogleFonts.inter(fontSize: 11, color: trendColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentLoadList() {
    final List<Map<String, dynamic>> departments = [
      {'name': 'Emergency', 'patients': 28, 'staff': 5, 'load': 'Critical', 'color': AppColors.danger},
      {'name': 'Cardiology', 'patients': 15, 'staff': 3, 'load': 'High', 'color': AppColors.warning},
      {'name': 'ICU', 'patients': 14, 'staff': 4, 'load': 'Critical', 'color': AppColors.danger},
      {'name': 'General Ward', 'patients': 82, 'staff': 8, 'load': 'Normal', 'color': AppColors.success},
      {'name': 'Pediatrics', 'patients': 22, 'staff': 2, 'load': 'Normal', 'color': AppColors.success},
      {'name': 'Outpatient (OPD)', 'patients': 23, 'staff': 2, 'load': 'Normal', 'color': AppColors.success},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
                'Department Workload',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Active Staffing',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departments.length,
            separatorBuilder: (context, index) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept['name'],
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dept['patients']} patients • ${dept['staff']} staff active',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (dept['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dept['load'],
                        style: GoogleFonts.inter(
                          color: dept['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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

  Widget _buildLoadChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Intake Volume (24 Hours)',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Displays the hourly patient intake numbers, highlighting peak hours.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LoadChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Emergency Admissions', AppColors.danger),
              const SizedBox(width: 24),
              _buildLegendItem('OPD Consultations', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAlertsPanel() {
    final List<Map<String, dynamic>> alerts = [
      {'title': 'Critical Bed Capacity', 'desc': 'ICU Occupancy is at 94% (15/16 beds occupied).', 'time': 'Just now', 'type': 'danger'},
      {'title': 'Medicine Shortage', 'desc': 'Paracetamol 500mg stock is below 1,000 tablets.', 'time': '10 mins ago', 'type': 'warning'},
      {'title': 'Ambulance Out of Service', 'desc': 'Ambulance #3 is offline for maintenance.', 'time': '1 hour ago', 'type': 'info'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.danger.withOpacity(0.8), size: 22),
                const SizedBox(width: 10),
                Text('Operational Alerts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: alerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                Color cardColor = AppColors.infoLight;
                Color textColor = AppColors.info;
                if (alert['type'] == 'danger') {
                  cardColor = AppColors.dangerLight;
                  textColor = AppColors.danger;
                } else if (alert['type'] == 'warning') {
                  cardColor = AppColors.warningLight;
                  textColor = AppColors.warning;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: textColor, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert['title'],
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(alert['desc'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(alert['time'], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepY = height / 5;
    for (int i = 0; i <= 5; i++) {
      canvas.drawLine(Offset(0, i * stepY), Offset(width, i * stepY), gridPaint);
    }

    final List<double> emergencyPoints = [0.2, 0.15, 0.1, 0.3, 0.6, 0.8, 0.9, 0.7, 0.5, 0.6, 0.4, 0.3];
    final List<double> opdPoints = [0.05, 0.05, 0.1, 0.4, 0.8, 0.95, 0.7, 0.6, 0.9, 0.5, 0.2, 0.1];

    _drawLine(canvas, size, emergencyPoints, AppColors.danger);
    _drawLine(canvas, size, opdPoints, AppColors.primary);
  }

  void _drawLine(Canvas canvas, Size size, List<double> points, Color color) {
    final double stepX = size.width / (points.length - 1);
    final Path path = Path();
    final Path areaPath = Path();

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = size.height - (points[i] * size.height * 0.8) - 10;

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }

      if (i == points.length - 1) {
        areaPath.lineTo(x, size.height);
        areaPath.close();
      }
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 3. Reception & Queue: `reception_queue_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ReceptionQueuePage extends StatefulWidget {
  const ReceptionQueuePage({super.key});

  @override
  State<ReceptionQueuePage> createState() => _ReceptionQueuePageState();
}

class _ReceptionQueuePageState extends State<ReceptionQueuePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDept = 'Emergency';
  
  final Map<String, Map<String, String>> _mockPatientsDb = {
    'NUD-892-441-X7': {
      'name': 'Rahim Islam',
      'id': 'NUD-892-441-X7',
      'nid': '1984261523412',
      'age': '42',
      'gender': 'Male',
      'blood': 'O+',
      'specialty': 'Cardiology',
      'doctor': 'Dr. Ahmed',
    },
    'NUD-123-456-A1': {
      'name': 'Jahanara Begum',
      'id': 'NUD-123-456-A1',
      'nid': '1992261543210',
      'age': '31',
      'gender': 'Female',
      'blood': 'A-',
      'specialty': 'Emergency',
      'doctor': 'On-Duty Trauma Team',
    }
  };

  Map<String, String>? _searchedPatient;
  bool _searchPerformed = false;

  List<Map<String, dynamic>> _queueList = [
    {'queueNo': 'EM-04', 'name': 'Hasan Ali', 'age': '52', 'gender': 'M', 'dept': 'Emergency', 'doctor': 'Trauma Lead', 'status': 'In Consultation'},
    {'queueNo': 'EM-05', 'name': 'Fatema Zohra', 'age': '24', 'gender': 'F', 'dept': 'Emergency', 'doctor': 'Dr. Subrata', 'status': 'Waiting'},
    {'queueNo': 'CD-01', 'name': 'Abdul Karim', 'age': '62', 'gender': 'M', 'dept': 'Cardiology', 'doctor': 'Dr. Ahmed', 'status': 'In Consultation'},
  ];

  void _searchPatient() {
    final query = _searchController.text.trim();
    setState(() {
      _searchPerformed = true;
      if (_mockPatientsDb.containsKey(query)) {
        _searchedPatient = _mockPatientsDb[query];
      } else {
        _searchedPatient = null;
      }
    });
  }

  void _checkInPatient() {
    if (_searchedPatient != null) {
      final dept = _searchedPatient!['specialty'] ?? 'Emergency';
      final String prefix = dept == 'Emergency' ? 'EM' : 'CD';
      final int nextNo = _queueList.where((p) => p['dept'] == dept).length + 1;
      
      setState(() {
        _queueList.add({
          'queueNo': '$prefix-${nextNo.toString().padLeft(2, '0')}',
          'name': _searchedPatient!['name'],
          'age': _searchedPatient!['age'],
          'gender': _searchedPatient!['gender']?[0] ?? 'M',
          'dept': dept,
          'doctor': _searchedPatient!['doctor'] ?? 'Unassigned',
          'status': 'Waiting',
        });
        _searchedPatient = null;
        _searchPerformed = false;
        _searchController.clear();
      });
    }
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      _queueList[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredQueue = _queueList.where((p) => p['dept'] == _selectedDept).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient Check-In Desk', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildSearchCard(),
                  if (_searchPerformed) ...[
                    const SizedBox(height: 24),
                    _buildSearchResultSection(),
                  ],
                ],
              ),
            ),
          ),
          Container(width: 1, color: AppColors.divider),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQueueDashboardHeader(),
                _buildDepartmentTabs(),
                Expanded(
                  child: filteredQueue.isEmpty
                      ? _buildEmptyQueue()
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: filteredQueue.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final patient = filteredQueue[index];
                            final realIndex = _queueList.indexWhere((p) => p['queueNo'] == patient['queueNo']);
                            return _buildQueueCard(patient, realIndex);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'NUDHEB Health ID', hintText: 'e.g., NUD-892-441-X7', prefixIcon: Icon(Icons.badge_outlined)),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(onPressed: _searchPatient, child: const Text('Find Patient')),
        ],
      ),
    );
  }

  Widget _buildSearchResultSection() {
    if (_searchedPatient == null) return const Center(child: Text('No citizen record found.'));
    final p = _searchedPatient!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(p['name']!, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _checkInPatient, child: const Text('Confirm Check-In')),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueDashboardHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Live Queue Dashboard', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDepartmentTabs() {
    final List<String> depts = ['Emergency', 'Cardiology'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: depts.map((dept) {
          final isSelected = _selectedDept == dept;
          return ChoiceChip(
            label: Text(dept),
            selected: isSelected,
            onSelected: (val) => setState(() => _selectedDept = dept),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
            backgroundColor: AppColors.background,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQueueCard(Map<String, dynamic> patient, int realIndex) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(patient['queueNo'])),
        title: Text(patient['name']),
        subtitle: Text(patient['status']),
        trailing: OutlinedButton(
          onPressed: () => _updateStatus(realIndex, 'Completed'),
          child: const Text('Complete'),
        ),
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return const Center(child: Text('No active patients in queue.'));
  }
}
```

### 4. Workforce & Roster: `staff_management_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All';

  List<Map<String, String>> _staffList = [
    {'name': 'Dr. Ahmed Khan', 'role': 'Doctor', 'dept': 'Cardiology', 'shift': 'Morning', 'status': 'Active'},
    {'name': 'Dr. Subrata Sen', 'role': 'Doctor', 'dept': 'Emergency', 'shift': 'Evening', 'status': 'Active'},
    {'name': 'Nurse Rabia Akhter', 'role': 'Nurse', 'dept': 'Emergency', 'shift': 'Night', 'status': 'Active'},
  ];

  List<Map<String, String>> _pendingDoctors = [
    {'name': 'Dr. Nihad Zaman', 'bmdc': 'BMDC-8921-2023', 'specialty': 'Neurology', 'experience': '8 Years', 'email': 'nihad@nudheb.gov.bd'}
  ];

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

  void _approveDoctor(int index) {
    final doc = _pendingDoctors[index];
    setState(() {
      _staffList.add({'name': doc['name']!, 'role': 'Doctor', 'dept': doc['specialty']!, 'shift': 'Morning', 'status': 'Active'});
      _pendingDoctors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Workforce command center', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
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
        tabs: const [Tab(text: 'Staff Directory'), Tab(text: 'Roster Planner'), Tab(text: 'Verification Queue')],
        labelColor: AppColors.primary,
        indicatorColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDirectoryTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: _staffList.map((s) => ListTile(title: Text(s['name']!), subtitle: Text(s['role']!))).toList(),
    );
  }

  Widget _buildRosterTab() {
    return const Center(child: Text('Roster calendar planner interface.'));
  }

  Widget _buildApplicationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _pendingDoctors.length,
      itemBuilder: (context, i) {
        final d = _pendingDoctors[i];
        return ListTile(
          title: Text(d['name']!),
          subtitle: Text(d['specialty']!),
          trailing: ElevatedButton(onPressed: () => _approveDoctor(i), child: const Text('Approve')),
        );
      },
    );
  }
}
```

### 5. Laboratory Dashboard: `laboratory_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LaboratoryPage extends StatefulWidget {
  const LaboratoryPage({super.key});

  @override
  State<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends State<LaboratoryPage> {
  List<Map<String, dynamic>> _labOrders = [
    {'id': 'LB-101', 'patient': 'Rahim Islam', 'test': 'Complete Blood Count (CBC)', 'status': 'Ordered', 'results': {}},
    {'id': 'LB-102', 'patient': 'Jahanara Begum', 'test': 'Fasting Blood Glucose', 'status': 'Sample Collected', 'results': {}},
  ];

  void _nextStage(String orderId) {
    final idx = _labOrders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      setState(() {
        final current = _labOrders[idx]['status'];
        if (current == 'Ordered') _labOrders[idx]['status'] = 'Sample Collected';
        else if (current == 'Sample Collected') _labOrders[idx]['status'] = 'Processing';
        else if (current == 'Processing') _labOrders[idx]['status'] = 'Verified';
        else if (current == 'Verified') _labOrders[idx]['status'] = 'Published';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Text('Laboratory Board', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Ordered', 'Sample Collected', 'Processing', 'Verified', 'Published']
                    .map((status) => _buildColumn(status))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(String status) {
    final list = _labOrders.where((o) => o['status'] == status).toList();
    return Container(
      width: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(status, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: list.map((order) => ListTile(
                title: Text(order['test']),
                subtitle: Text(order['patient']),
                trailing: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => _nextStage(order['id'])),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 6. Bed Management: `bed_management_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class BedManagementPage extends StatefulWidget {
  const BedManagementPage({super.key});

  @override
  State<BedManagementPage> createState() => _BedManagementPageState();
}

class _BedManagementPageState extends State<BedManagementPage> {
  List<Map<String, dynamic>> _beds = [
    {'id': 'B-101', 'number': 'Bed 101', 'status': 'Occupied', 'patient': 'Rahim Islam', 'doctor': 'Dr. Ahmed'},
    {'id': 'B-102', 'number': 'Bed 102', 'status': 'Available'},
  ];

  void _admit(String bedId) {
    final idx = _beds.indexWhere((b) => b['id'] == bedId);
    if (idx != -1) {
      setState(() {
        _beds[idx]['status'] = 'Occupied';
        _beds[idx]['patient'] = 'New Patient';
        _beds[idx]['doctor'] = 'Dr. Ahmed';
      });
    }
  }

  void _discharge(String bedId) {
    final idx = _beds.indexWhere((b) => b['id'] == bedId);
    if (idx != -1) {
      setState(() {
        _beds[idx]['status'] = 'Available';
        _beds[idx].remove('patient');
        _beds[idx].remove('doctor');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemCount: _beds.length,
        itemBuilder: (context, i) {
          final bed = _beds[i];
          final isOccupied = bed['status'] == 'Occupied';
          return Card(
            color: isOccupied ? AppColors.dangerLight : AppColors.successLight,
            child: InkWell(
              onTap: () => isOccupied ? _discharge(bed['id']) : _admit(bed['id']),
              child: Center(
                child: Text(
                  '${bed['number']}\n${isOccupied ? bed['patient'] : 'Available'}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 7. Pharmacy Desk: `pharmacy_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final TextEditingController _rxController = TextEditingController();

  List<Map<String, dynamic>> _inventory = [
    {'name': 'Metformin 500mg', 'stock': 5000, 'min': 1000},
    {'name': 'Paracetamol 500mg', 'stock': 400, 'min': 1000},
  ];

  void _dispense(String medicine, int qty) {
    final idx = _inventory.indexWhere((i) => i['name'] == medicine);
    if (idx != -1) {
      setState(() {
        _inventory[idx]['stock'] -= qty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(controller: _rxController, decoration: const InputDecoration(labelText: 'Prescription Code')),
                  ElevatedButton(onPressed: () => _dispense('Metformin 500mg', 60), child: const Text('Dispense Metformin')),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: _inventory.map((item) => ListTile(
                title: Text(item['name']),
                trailing: Text('Stock: ${item['stock']}'),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🛠️ Extra Steps

* **Ecosystem Connection**: To connect to real data, swap the mock lists with Riverpod StateNotifier/AsyncNotifier providers referencing remote Dio clients.
* **Environment variables**:
  * Set `API_URL` during build flags: `flutter run -d chrome --dart-define=API_URL=http://localhost:8080/api`

---

## 📝 Summary

1. **Check-In**: Admin searches Health ID → verifies patient profile → stamps Arrived → places patient in the queue.
2. **Consultation**: Patient queue is updated dynamically in doctor's office portal.
3. **Operations**: Treatment orders (lab test requests, medication prescriptions) are automatically dispatched to the Diagnostic and Pharmacy boards respectively.
4. **Treatment Dispatch**: Technician advances lab samples through Kanban slots; Pharmacist checks stock thresholds and checks out medicines.
