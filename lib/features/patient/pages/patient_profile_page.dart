import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/patient_profile.dart';
import '../presentation/providers/patient_providers.dart';

class PatientProfilePage extends ConsumerStatefulWidget {
  const PatientProfilePage({super.key});

  @override
  ConsumerState<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends ConsumerState<PatientProfilePage> {
  bool _isEditing = false;
  int _currentStep = 0;
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late TextEditingController _maritalStatusController;
  late TextEditingController _presentAddressController;
  late TextEditingController _permanentAddressController;
  
  // Emergency Contact editing controllers
  late TextEditingController _iceNameController;
  late TextEditingController _iceRelationController;
  late TextEditingController _icePhoneController;

  // New controllers for full editable properties
  late TextEditingController _genderController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _nationalIdController;
  late TextEditingController _bpSystolicController;
  late TextEditingController _bpDiastolicController;
  late TextEditingController _bloodGlucoseController;
  late TextEditingController _heartRateController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _occupationController = TextEditingController();
    _maritalStatusController = TextEditingController();
    _presentAddressController = TextEditingController();
    _permanentAddressController = TextEditingController();
    _iceNameController = TextEditingController();
    _iceRelationController = TextEditingController();
    _icePhoneController = TextEditingController();

    _genderController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _nationalIdController = TextEditingController();
    _bpSystolicController = TextEditingController();
    _bpDiastolicController = TextEditingController();
    _bloodGlucoseController = TextEditingController();
    _heartRateController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _maritalStatusController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    _iceNameController.dispose();
    _iceRelationController.dispose();
    _icePhoneController.dispose();

    _genderController.dispose();
    _bloodGroupController.dispose();
    _nationalIdController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _bloodGlucoseController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initFields(PatientProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _occupationController.text = profile.occupation;
    _maritalStatusController.text = profile.maritalStatus;
    _presentAddressController.text = profile.presentAddress;
    _permanentAddressController.text = profile.permanentAddress;
    _genderController.text = profile.gender;
    _bloodGroupController.text = profile.bloodGroup;
    _nationalIdController.text = profile.nationalId;
    _bpSystolicController.text = profile.vitals.bpSystolic;
    _bpDiastolicController.text = profile.vitals.bpDiastolic;
    _bloodGlucoseController.text = profile.vitals.bloodGlucose;
    _heartRateController.text = profile.vitals.heartRate;
    _weightController.text = profile.vitals.weight;

    if (profile.emergencyContacts.isNotEmpty) {
      _iceNameController.text = profile.emergencyContacts[0].name;
      _iceRelationController.text = profile.emergencyContacts[0].relationship;
      _icePhoneController.text = profile.emergencyContacts[0].phone;
    } else {
      _iceNameController.clear();
      _iceRelationController.clear();
      _icePhoneController.clear();
    }
  }

  void _startEditing(PatientProfile profile) {
    _initFields(profile);
    setState(() {
      _isEditing = true;
      _currentStep = 0;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveProfile(PatientProfile profile) async {
    final updatedICE = [
      EmergencyContact(
        name: _iceNameController.text.trim(),
        relationship: _iceRelationController.text.trim(),
        phone: _icePhoneController.text.trim(),
      )
    ];

    final updatedProfile = profile.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      occupation: _occupationController.text.trim(),
      maritalStatus: _maritalStatusController.text.trim(),
      presentAddress: _presentAddressController.text.trim(),
      permanentAddress: _permanentAddressController.text.trim(),
      gender: _genderController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      emergencyContacts: updatedICE,
      vitals: VitalSign(
        bpSystolic: _bpSystolicController.text.trim(),
        bpDiastolic: _bpDiastolicController.text.trim(),
        bloodGlucose: _bloodGlucoseController.text.trim(),
        heartRate: _heartRateController.text.trim(),
        weight: _weightController.text.trim(),
        lastUpdated: DateTime.now(),
      ),
    );

    final success = await ref.read(patientProfileProvider.notifier).updateProfile(updatedProfile);
    if (success) {
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (profile) {
          if (_isEditing) {
            return _buildEditWizard(profile);
          }
          return _buildProfileView(profile);
        },
      ),
    );
  }

  Widget _buildProfileView(PatientProfile profile) {
    final dobStr = "${profile.dateOfBirth.day} ${_getMonthName(profile.dateOfBirth.month)} ${profile.dateOfBirth.year}";
    final age = DateTime.now().year - profile.dateOfBirth.year;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Health Profile', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _profileHeader(profile),
                    const SizedBox(height: 20),
                    _infoSection('Personal Information', [
                      _infoRow('Full Name', profile.name),
                      _infoRow('Date of Birth', dobStr),
                      _infoRow('Age', '$age years'),
                      _infoRow('Gender', profile.gender),
                      _infoRow('Blood Group', profile.bloodGroup),
                      _infoRow('National ID (NID)', profile.nationalId),
                      _infoRow('Phone Number', profile.phone),
                      _infoRow('Occupation', profile.occupation),
                      _infoRow('Marital Status', profile.maritalStatus),
                    ]),
                    const SizedBox(height: 20),
                    _infoSection('Addresses', [
                      _infoRow('Present Address', profile.presentAddress),
                      _infoRow('Permanent Address', profile.permanentAddress),
                    ]),
                    const SizedBox(height: 20),
                    _infoSection('Emergency Contacts', [
                      if (profile.emergencyContacts.isEmpty)
                        Text('No emergency contacts defined.', style: GoogleFonts.inter(color: AppColors.textMuted))
                      else
                        ...profile.emergencyContacts.map((c) => _contactRow(c.name, c.relationship, c.phone)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _medicalSection('Allergies & Reactions', [
                      if (profile.allergies.isEmpty)
                        Text('No known allergies.', style: GoogleFonts.inter(color: AppColors.textMuted))
                      else
                        ...profile.allergies.map((a) => _allergyChip(a.allergen, a.severity, _getAllergyColor(a.severity))),
                    ]),
                    const SizedBox(height: 20),
                    _medicalSection('Chronic Diseases', [
                      if (profile.chronicDiseases.isEmpty)
                        Text('No registered chronic conditions.', style: GoogleFonts.inter(color: AppColors.textMuted))
                      else
                        ...profile.chronicDiseases.map((d) {
                          final diagnosedStr = "Diagnosed ${d.diagnosedDate.year}";
                          return _diseaseRow(d.diseaseName, diagnosedStr, d.status);
                        }),
                    ]),
                    const SizedBox(height: 20),
                    _medicalSection('Current Vitals', [
                      _vitalRow('Blood Pressure', '${profile.vitals.bpSystolic}/${profile.vitals.bpDiastolic} mmHg', Icons.favorite_rounded, AppColors.danger),
                      _vitalRow('Blood Glucose', '${profile.vitals.bloodGlucose} mg/dL', Icons.bloodtype_rounded, AppColors.warning),
                      _vitalRow('Heart Rate', '${profile.vitals.heartRate} bpm', Icons.monitor_heart_rounded, AppColors.success),
                      _vitalRow('Body Weight', '${profile.vitals.weight} kg', Icons.scale_rounded, AppColors.info),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditWizard(PatientProfile profile) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Update Profile Wizard', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: _cancelEditing, icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 24),
              _buildWizardNavigation(profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _progressStep(0, 'Personal'),
        _progressLine(0),
        _progressStep(1, 'Addresses'),
        _progressLine(1),
        _progressStep(2, 'Emergency'),
        _progressLine(2),
        _progressStep(3, 'Vitals'),
      ],
    );
  }

  Widget _progressStep(int stepIndex, String label) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;
    final color = isActive ? AppColors.primary : (isDone ? AppColors.secondary : AppColors.textMuted);

    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : (isDone ? AppColors.secondary : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text('${stepIndex + 1}', style: GoogleFonts.inter(color: isActive ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: isActive ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  Widget _progressLine(int stepIndex) {
    final isDone = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 2,
        color: isDone ? AppColors.secondary : AppColors.divider,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wizardTextField('Full Name', _nameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Phone Number', _phoneController, Icons.phone_android_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Occupation', _occupationController, Icons.work_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Marital Status', _maritalStatusController, Icons.people_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Gender', _genderController, Icons.transgender_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Blood Group', _bloodGroupController, Icons.bloodtype_outlined),
            const SizedBox(height: 16),
            _wizardTextField('National ID (NID)', _nationalIdController, Icons.badge_outlined),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _wizardTextField('Present Address', _presentAddressController, Icons.home_outlined, maxLines: 2),
            const SizedBox(height: 16),
            _wizardTextField('Permanent Address', _permanentAddressController, Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _permanentAddressController.text = _presentAddressController.text;
                });
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Present to Permanent Address'),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Primary Emergency Contact (ICE)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _wizardTextField('Contact Name', _iceNameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Relationship', _iceRelationController, Icons.family_restroom_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Contact Phone', _icePhoneController, Icons.phone_rounded),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Vitals', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _wizardTextField('BP Systolic (mmHg)', _bpSystolicController, Icons.favorite_rounded),
            const SizedBox(height: 16),
            _wizardTextField('BP Diastolic (mmHg)', _bpDiastolicController, Icons.favorite_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Blood Glucose (mg/dL)', _bloodGlucoseController, Icons.bloodtype_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Heart Rate (bpm)', _heartRateController, Icons.monitor_heart_rounded),
            const SizedBox(height: 16),
            _wizardTextField('Body Weight (kg)', _weightController, Icons.scale_rounded),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _wizardTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildWizardNavigation(PatientProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            TextButton(onPressed: _cancelEditing, child: const Text('Cancel')),
            const SizedBox(width: 12),
            if (_currentStep < 3)
              ElevatedButton(
                onPressed: () => setState(() => _currentStep++),
                child: const Text('Next'),
              )
            else
              ElevatedButton(
                onPressed: () => _saveProfile(profile),
                child: const Text('Save Changes'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _profileHeader(PatientProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Health ID: ${profile.healthId}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                  child: Text('Organ Donor ❤️', style: GoogleFonts.inter(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _startEditing(profile),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _contactRow(String name, String relation, String phone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, size: 18, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(child: Text('$name ($relation)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500))),
          Text(phone, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _medicalSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _allergyChip(String name, String severity, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: color, size: 18),
        const SizedBox(width: 10),
        Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
          child: Text(severity, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _diseaseRow(String name, String diagnosed, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.monitor_heart_rounded, size: 18, color: AppColors.danger),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(diagnosed, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(4)),
          child: Text(status, style: GoogleFonts.inter(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _vitalRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Color _getAllergyColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppColors.danger;
      case 'moderate':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
