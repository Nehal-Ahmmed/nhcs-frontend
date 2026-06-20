import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/govt_providers.dart';
import '../data/models/govt_registry_models.dart';

class GovtRegistriesPage extends ConsumerStatefulWidget {
  const GovtRegistriesPage({super.key});

  @override
  ConsumerState<GovtRegistriesPage> createState() => _GovtRegistriesPageState();
}

class _GovtRegistriesPageState extends ConsumerState<GovtRegistriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _searchController.clear();
        _searchQuery = '';
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citizens = ref.watch(govtCitizenRegistryProvider);
    final doctors = ref.watch(govtDoctorRegistryProvider);
    final hospitals = ref.watch(govtHospitalRegistryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabAndSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCitizensTab(citizens),
                _buildDoctorsTab(doctors),
                _buildHospitalsTab(hospitals),
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
                'National Registries Board',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Official registries index for all registered citizens, practitioners, and clinical facilities.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabAndSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: const [
              Tab(text: 'Citizen Directory'),
              Tab(text: 'Practitioner Board (BMDC)'),
              Tab(text: 'Hospital Registry'),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 320,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: _tabController.index == 0
                        ? 'Search citizens by Name or Health ID...'
                        : (_tabController.index == 1
                            ? 'Search doctors by Name, Spec or License...'
                            : 'Search hospitals by Name or Facility ID...'),
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitizensTab(List<CitizenProfile> list) {
    final filtered = list.where((c) {
      return c.name.toLowerCase().contains(_searchQuery) || c.healthId.toLowerCase().contains(_searchQuery);
    }).toList();

    return _buildContainerWrapper(
      child: filtered.isEmpty
          ? _buildEmptyState('No registered citizens found.')
          : ListView(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(1),
                    6: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.8))),
                      ),
                      children: [
                        _tableHeader('Health ID'),
                        _tableHeader('Citizen Name'),
                        _tableHeader('Age'),
                        _tableHeader('Gender'),
                        _tableHeader('Division'),
                        _tableHeader('Blood Group'),
                        _tableHeader('Registered Date'),
                      ],
                    ),
                    ...filtered.map((c) {
                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.3))),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.healthId, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('${c.age}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.gender, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.division, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.bloodGroup, style: GoogleFonts.inter(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(c.registrationDate, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
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

  Widget _buildDoctorsTab(List<DoctorProfile> list) {
    final filtered = list.where((d) {
      return d.name.toLowerCase().contains(_searchQuery) ||
          d.bmdcId.toLowerCase().contains(_searchQuery) ||
          d.specialization.toLowerCase().contains(_searchQuery);
    }).toList();

    return _buildContainerWrapper(
      child: filtered.isEmpty
          ? _buildEmptyState('No registered practitioners found.')
          : ListView(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(3),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                    6: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.8))),
                      ),
                      children: [
                        _tableHeader('BMDC ID'),
                        _tableHeader('Practitioner Name'),
                        _tableHeader('Specialization'),
                        _tableHeader('Affiliated Hospital'),
                        _tableHeader('Registered'),
                        _tableHeader('Status'),
                        _tableHeader('Actions'),
                      ],
                    ),
                    ...filtered.map((d) {
                      final isActive = d.status == 'Active';

                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.3))),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(d.bmdcId, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(d.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(d.specialization, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(d.affiliatedHospital, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(d.registrationDate, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.successLight : AppColors.dangerLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  d.status,
                                  style: GoogleFonts.inter(color: isActive ? AppColors.success : AppColors.danger, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                if (isActive)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () {
                                      ref.read(govtDoctorRegistryProvider.notifier).updateDoctorStatus(d.bmdcId, 'Suspended');
                                    },
                                    child: Text('Suspend License', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () {
                                      ref.read(govtDoctorRegistryProvider.notifier).updateDoctorStatus(d.bmdcId, 'Active');
                                    },
                                    child: Text('Activate License', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
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

  Widget _buildHospitalsTab(List<HospitalProfile> list) {
    final filtered = list.where((h) {
      return h.name.toLowerCase().contains(_searchQuery) || h.facilityId.toLowerCase().contains(_searchQuery);
    }).toList();

    return _buildContainerWrapper(
      child: filtered.isEmpty
          ? _buildEmptyState('No registered facilities found.')
          : ListView(
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                    5: FlexColumnWidth(2),
                    6: FlexColumnWidth(2),
                    7: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.8))),
                      ),
                      children: [
                        _tableHeader('Facility ID'),
                        _tableHeader('Hospital Name'),
                        _tableHeader('Division'),
                        _tableHeader('Classification'),
                        _tableHeader('Beds Capacity'),
                        _tableHeader('Compliance Grade'),
                        _tableHeader('Status'),
                        _tableHeader('Actions'),
                      ],
                    ),
                    ...filtered.map((h) {
                      Color statusColor = AppColors.success;
                      Color statusBg = AppColors.successLight;
                      if (h.status == 'Suspended') {
                        statusColor = AppColors.danger;
                        statusBg = AppColors.dangerLight;
                      } else if (h.status == 'Under Review') {
                        statusColor = AppColors.warning;
                        statusBg = AppColors.warningLight;
                      }

                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.3))),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(h.facilityId, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(h.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(h.division, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(h.classification, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('${h.occupiedBeds}/${h.totalBeds} Occupied', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('${h.complianceScore}%', style: GoogleFonts.inter(color: h.complianceScore >= 90 ? AppColors.success : (h.complianceScore >= 75 ? AppColors.warning : AppColors.danger), fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                child: Text(h.status, style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                // Redirect to Compliance center (tab index 4)
                                ref.read(govtNavigationProvider.notifier).state = 4;
                              },
                              child: Text('Inspect / Audit', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
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

  Widget _buildContainerWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: child,
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(msg, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
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
}
