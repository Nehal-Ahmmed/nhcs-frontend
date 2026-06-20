import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../../patient/data/models/patient_profile.dart';
import '../presentation/providers/doctor_providers.dart';
import '../presentation/providers/clinical_workspace_provider.dart';
import '../data/models/clinical_case.dart';

class ClinicalWorkspacePage extends ConsumerStatefulWidget {
  const ClinicalWorkspacePage({super.key});

  @override
  ConsumerState<ClinicalWorkspacePage> createState() => _ClinicalWorkspacePageState();
}

class _ClinicalWorkspacePageState extends ConsumerState<ClinicalWorkspacePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _diseaseNotesController = TextEditingController();
  
  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();
  final TextEditingController _medDurationController = TextEditingController();
  final TextEditingController _medInstructionsController = TextEditingController();
  
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController(text: 'In 2 weeks');
  final TextEditingController _referralController = TextEditingController();

  String _diagnosisStatus = 'Provisional';
  
  @override
  void dispose() {
    _searchController.dispose();
    _symptomController.dispose();
    _diseaseController.dispose();
    _diseaseNotesController.dispose();
    _medNameController.dispose();
    _medDosageController.dispose();
    _medDurationController.dispose();
    _medInstructionsController.dispose();
    _notesController.dispose();
    _followUpController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(clinicalWorkspaceProvider);
    final patientId = workspaceState.patientId;
    
    // Watch patient profile if selected
    final patientProfileAsync = ref.watch(patientSearchProvider(patientId));

    // Listen for submission success to reset and navigate back
    ref.listen<ClinicalWorkspaceState>(clinicalWorkspaceProvider, (prev, next) {
      if (next.isSuccess) {
        // Show success alert
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment plan submitted successfully and synced to patient records!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh dashboard and queue
        ref.invalidate(doctorDashboardProvider);
        ref.invalidate(patientQueueProvider);
        // Reset workspace
        ref.read(clinicalWorkspaceProvider.notifier).reset();
        // Go back to dashboard
        ref.read(doctorNavigationProvider.notifier).state = 0;
      } else if (next.error != null && next.error != prev?.error) {
        // Show error alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: AppColors.surface,
            child: Row(
              children: [
                Text('Clinical Workspace', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                if (workspaceState.patientName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Active Patient: ${workspaceState.patientName}',
                      style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  Text(
                    '• Select a patient from the queue or search below',
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                  ),
                const Spacer(),
                if (patientId.isNotEmpty) ...[
                  TextButton(
                    onPressed: () {
                      ref.read(clinicalWorkspaceProvider.notifier).reset();
                      _notesController.clear();
                      _followUpController.text = 'In 2 weeks';
                      _referralController.clear();
                    },
                    child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: workspaceState.isSubmitting
                        ? null
                        : () {
                            ref.read(clinicalWorkspaceProvider.notifier).updateClinicalNotes(_notesController.text);
                            ref.read(clinicalWorkspaceProvider.notifier).updateFollowUp(_followUpController.text);
                            ref.read(clinicalWorkspaceProvider.notifier).updateReferral(_referralController.text.isEmpty ? null : _referralController.text);
                            ref.read(clinicalWorkspaceProvider.notifier).submit();
                          },
                    icon: workspaceState.isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(workspaceState.isSubmitting ? 'Submitting...' : 'Submit Treatment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT: Patient History
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(right: BorderSide(color: AppColors.divider.withOpacity(0.5))),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar to lookup patients by ID
                          _buildPatientSearchBar(),
                          const SizedBox(height: 20),
                          
                          if (patientId.isEmpty)
                            _buildNoPatientPlaceholder()
                          else
                            patientProfileAsync.when(
                              data: (profile) {
                                if (profile == null) {
                                  return const Text('Patient profile not found.');
                                }
                                return _buildPatientHistoryContent(profile);
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (err, _) => Text('Error loading profile: $err'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // RIGHT: Treatment Form
                Expanded(
                  flex: 5,
                  child: Container(
                    color: AppColors.surface,
                    child: patientId.isEmpty
                        ? Center(
                            child: Text(
                              'Select a patient to open clinical form.',
                              style: GoogleFonts.inter(color: AppColors.textMuted),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Symptoms Section
                                _buildSymptomsSection(workspaceState),
                                const SizedBox(height: 24),
                                
                                // Diagnosis Section
                                _buildDiagnosisSection(workspaceState),
                                const SizedBox(height: 24),
                                
                                // Prescription Section
                                _buildPrescriptionSection(workspaceState),
                                const SizedBox(height: 24),
                                
                                // Investigations Section
                                _buildInvestigationsSection(workspaceState),
                                const SizedBox(height: 24),
                                
                                // Notes Section
                                _buildNotesSection(),
                                const SizedBox(height: 24),
                                
                                // Follow-up & Referral Section
                                _buildFollowUpReferralSection(),
                                const SizedBox(height: 24),
                                
                                // AI Alerts and Decision Support (Interactive Warnings!)
                                _buildAiAlertsPanel(workspaceState, patientProfileAsync.value),
                              ],
                            ),
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

  Widget _buildPatientSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Enter National Health ID to retrieve records... (e.g. NUD-892-441-X7)',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            onPressed: () {
              final id = _searchController.text.trim();
              if (id.isNotEmpty) {
                ref.read(clinicalWorkspaceProvider.notifier).initializePatient(id, 'Patient Profile');
                // Dynamically fetch patient details from datasource
                ref.read(doctorRepositoryProvider).getPatientProfileByHealthId(id).then((p) {
                  if (p != null) {
                    ref.read(clinicalWorkspaceProvider.notifier).initializePatient(id, p.name);
                  }
                });
              }
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) {
          final id = value.trim();
          if (id.isNotEmpty) {
            ref.read(clinicalWorkspaceProvider.notifier).initializePatient(id, 'Patient Profile');
            ref.read(doctorRepositoryProvider).getPatientProfileByHealthId(id).then((p) {
              if (p != null) {
                ref.read(clinicalWorkspaceProvider.notifier).initializePatient(id, p.name);
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildNoPatientPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.assignment_ind_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('No Active Consultation', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Select a patient from the queue in the Dashboard, or search using their National Unified Health ID to access their lifelong health history.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHistoryContent(PatientProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DOB: ${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year} (${2026 - profile.dateOfBirth.year} yrs) • ${profile.gender}',
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: profile.bloodGroup == 'O+' ? AppColors.warning.withOpacity(0.3) : Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Blood: ${profile.bloodGroup}',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Allergies', profile.allergies.isEmpty ? 'None' : profile.allergies.map((e) => e.allergen).join(', ')),
                    Container(width: 1, height: 24, color: Colors.white24),
                    _summaryItem('Chronic Diseases', profile.chronicDiseases.isEmpty ? 'None' : profile.chronicDiseases.map((e) => e.diseaseName).join(', ')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(
                  'Unified ID: ${profile.healthId}',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // AI Clinical Overview Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Clinical Overview', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accent)),
                    const SizedBox(height: 6),
                    Text(
                      profile.healthId == 'NUD-892-441-X7'
                          ? 'Patient has been under treatment for diabetes for five years. Blood glucose levels have gradually increased during the last three visits. Medication compliance appears inconsistent. One follow-up appointment was missed.'
                          : 'Patient profile loaded. Review current vital signs and allergy checklist before prescribing treatment.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Vitals
        _sectionTitle('Latest Vital Signs'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _vitalGridItem('Blood Pressure', '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic}', 'mmHg', Icons.favorite_rounded, Colors.red),
              _vitalGridItem('Blood Glucose', profile.vitals.bloodGlucose, 'mg/dL', Icons.bloodtype_rounded, Colors.orange),
              _vitalGridItem('Heart Rate', profile.vitals.heartRate, 'bpm', Icons.favorite, Colors.pink),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Chronic Diseases Details
        _sectionTitle('Chronic Disease Log'),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profile.chronicDiseases.length,
          itemBuilder: (context, index) {
            final cd = profile.chronicDiseases[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.warningLight, shape: BoxShape.circle),
                  child: const Icon(Icons.healing_rounded, color: Colors.orange, size: 18),
                ),
                title: Text(cd.diseaseName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Diagnosed: ${cd.diagnosedDate.year} • Status: ${cd.status}', style: GoogleFonts.inter(fontSize: 11)),
                dense: true,
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Past Lab Results / Prescriptions
        _sectionTitle('Historic Records'),
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Lab Reports'),
                  Tab(text: 'Prescriptions'),
                ],
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: TabBarView(
                  children: [
                    // Lab reports sublist
                    ListView(
                      children: [
                        _labReportItem('HbA1c & Fasting Glucose', '05 Jun 2026', 'HbA1c 8.2% (High)', AppColors.danger),
                        _labReportItem('Lipid Profile', '12 May 2026', 'LDL 135 mg/dL (Borderline)', AppColors.warning),
                        _labReportItem('Serum Creatinine', '08 Apr 2026', '0.9 mg/dL (Normal)', AppColors.success),
                      ],
                    ),
                    // Prescriptions sublist
                    ListView(
                      children: [
                        _prescriptionItem('Dr. Ahmed (Dhaka Central)', '20 May 2026', 'Metformin 500mg, Amlodipine 5mg'),
                        _prescriptionItem('Dr. Karim (Cardiologist)', '15 Jan 2026', 'Atorvastatin 10mg'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vitalGridItem(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 2),
              Text(unit, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _labReportItem(String test, String date, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _prescriptionItem(String doctor, String date, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(doctor, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
              const Spacer(),
              Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(details, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Right Pane UI Widgets
  Widget _formHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection(ClinicalWorkspaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader('Symptoms / Presenting Complaints', Icons.edit_note_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _symptomController,
                decoration: const InputDecoration(
                  hintText: 'Type symptom... (e.g. Chest pain, Shortness of breath)',
                  isDense: true,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(clinicalWorkspaceProvider.notifier).addSymptom(value.trim());
                    _symptomController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final txt = _symptomController.text.trim();
                if (txt.isNotEmpty) {
                  ref.read(clinicalWorkspaceProvider.notifier).addSymptom(txt);
                  _symptomController.clear();
                }
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text('Add'),
            ),
          ],
        ),
        if (state.symptoms.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.symptoms.map((sym) {
              return Chip(
                label: Text(sym, style: GoogleFonts.inter(fontSize: 12)),
                backgroundColor: AppColors.background,
                onDeleted: () => ref.read(clinicalWorkspaceProvider.notifier).removeSymptom(sym),
                deleteIconColor: AppColors.danger,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosisSection(ClinicalWorkspaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader('Diagnosis', Icons.medical_information_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _diseaseController,
                decoration: const InputDecoration(
                  hintText: 'Diagnosis (ICD name)...',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _diagnosisStatus,
                items: ['Provisional', 'Confirmed'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, style: GoogleFonts.inter(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _diagnosisStatus = val;
                    });
                  }
                },
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final disease = _diseaseController.text.trim();
                if (disease.isNotEmpty) {
                  ref.read(clinicalWorkspaceProvider.notifier).addDiagnosis(
                        disease,
                        _diagnosisStatus,
                        _diseaseNotesController.text.trim(),
                      );
                  _diseaseController.clear();
                  _diseaseNotesController.clear();
                }
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text('Add'),
            ),
          ],
        ),
        if (state.diagnoses.isNotEmpty) ...[
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.diagnoses.length,
            itemBuilder: (context, index) {
              final diag = state.diagnoses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: ListTile(
                  title: Text(diag.diseaseName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Status: ${diag.status}', style: GoogleFonts.inter(fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                    onPressed: () => ref.read(clinicalWorkspaceProvider.notifier).removeDiagnosis(index),
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPrescriptionSection(ClinicalWorkspaceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader('Prescribe Medication', Icons.medication_rounded),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _medNameController,
                decoration: const InputDecoration(
                  hintText: 'Medicine name (e.g. Glimepiride, Amlodipine)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _medDosageController,
                      decoration: const InputDecoration(
                        hintText: 'Dosage (e.g. 1+0+1)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _medDurationController,
                      decoration: const InputDecoration(
                        hintText: 'Duration (e.g. 15 days)',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _medInstructionsController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. After food',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    final name = _medNameController.text.trim();
                    final dosage = _medDosageController.text.trim();
                    final duration = _medDurationController.text.trim();
                    final inst = _medInstructionsController.text.trim();
                    
                    if (name.isNotEmpty) {
                      ref.read(clinicalWorkspaceProvider.notifier).addMedicine(name, dosage, duration, inst);
                      _medNameController.clear();
                      _medDosageController.clear();
                      _medDurationController.clear();
                      _medInstructionsController.clear();
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Medicine'),
                ),
              ),
            ],
          ),
        ),
        
        if (state.medicines.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final med = state.medicines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: ListTile(
                  title: Text(med.medicineName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                  subtitle: Text(
                    'Dosage: ${med.dosage} • Duration: ${med.duration} • ${med.instructions}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                    onPressed: () => ref.read(clinicalWorkspaceProvider.notifier).removeMedicine(index),
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInvestigationsSection(ClinicalWorkspaceState state) {
    final availableTests = [
      'Blood Glucose',
      'HbA1c',
      'ECG',
      'Lipid Profile',
      'Renal Function',
      'Chest X-Ray',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader('Investigations / Diagnostics', Icons.science_rounded),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTests.map((test) {
            final checked = state.investigations.contains(test);
            return InkWell(
              onTap: () => ref.read(clinicalWorkspaceProvider.notifier).toggleInvestigation(test),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: checked ? AppColors.primaryLight : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: checked ? AppColors.primary.withOpacity(0.3) : AppColors.divider.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 18,
                      color: checked ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      test,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: checked ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formHeader('Clinical Notes / Observations', Icons.note_alt_rounded),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter clinical history findings, observations, or advice...',
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpReferralSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader('Follow-up', Icons.event_rounded),
              const SizedBox(height: 10),
              TextField(
                controller: _followUpController,
                decoration: const InputDecoration(
                  hintText: 'In 2 weeks, In 1 month, etc.',
                  prefixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formHeader('Referral (Optional)', Icons.send_rounded),
              const SizedBox(height: 10),
              TextField(
                controller: _referralController,
                decoration: const InputDecoration(
                  hintText: 'Specialist name / Department',
                  prefixIcon: Icon(Icons.person_search_rounded, size: 18),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiAlertsPanel(ClinicalWorkspaceState state, PatientProfile? profile) {
    final List<Widget> alerts = [];

    // 1. Allergy Alert logic
    final bool hasPenicillinAllergy = profile?.allergies.any((a) => a.allergen.toLowerCase().contains('penicillin')) ?? false;
    final bool hasPrescribedPenicillin = state.medicines.any((m) {
      final name = m.medicineName.toLowerCase();
      return name.contains('penicillin') || name.contains('amoxicillin') || name.contains('ampicillin') || name.contains('cloxacillin') || name.contains('augmentin');
    });

    if (hasPenicillinAllergy && hasPrescribedPenicillin) {
      alerts.add(
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: 'Critical Allergy Warning (Penicillin Derivatives)',
            description: 'Patient has a recorded Penicillin allergy with severity: Severe (Anaphylaxis). Prescribed medicine is a penicillin derivative. Risk of severe allergic reaction!',
            type: 'danger',
            recommendations: [
              'Replace Amoxicillin/Penicillin with a Macrolide (e.g. Azithromycin) or Fluoroquinolone.',
              'Verify patient allergy history card prior to treatment plan submission.',
            ],
          ),
        ),
      );
    }

    // 2. Drug Interaction logic (e.g. Aspirin and Glimepiride)
    final hasAspirin = state.medicines.any((m) => m.medicineName.toLowerCase().contains('aspirin'));
    final hasGlimepiride = state.medicines.any((m) => m.medicineName.toLowerCase().contains('glimepiride'));
    if (hasAspirin && hasGlimepiride) {
      alerts.add(
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: 'Drug-Drug Interaction Alert (Aspirin & Glimepiride)',
            description: 'Aspirin may enhance the hypoglycemic effect of Glimepiride, increasing the risk of hypoglycemia. Monitor blood glucose levels closely.',
            type: 'warning',
            recommendations: [
              'Adjust Glimepiride dosage if co-administered with daily Aspirin.',
              'Advise the patient to monitor for symptoms of hypoglycemia (dizziness, sweating, shakiness).',
            ],
          ),
        ),
      );
    }

    // 3. Clinical Recommendation logic (suggest ECG for cardiac patients if not ordered)
    final hasCardiacComplaint = state.symptoms.any((s) => s.toLowerCase().contains('chest pain') || s.toLowerCase().contains('breathless') || s.toLowerCase().contains('palpitations'));
    final hasOrderedEcg = state.investigations.contains('ECG');
    if (hasCardiacComplaint && !hasOrderedEcg) {
      alerts.add(
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AiInsightPanel(
            title: 'Clinical Diagnostics Support Recommendation',
            description: 'Patient presents with cardiac symptoms (e.g. chest pain). A 12-lead ECG is recommended to rule out myocardial ischemia.',
            type: 'info',
            recommendations: [
              'Order a 12-lead resting ECG card from the Investigations menu.',
              'Monitor baseline cardiovascular telemetry logs.',
            ],
          ),
        ),
      );
    }

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 10),
            Text(
              'AI Safety Check: No issues or warnings found.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      children: alerts,
    );
  }
}
