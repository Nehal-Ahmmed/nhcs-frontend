import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/govt_providers.dart';
import '../data/models/govt_registry_models.dart';

class GovtCompliancePage extends ConsumerStatefulWidget {
  const GovtCompliancePage({super.key});

  @override
  ConsumerState<GovtCompliancePage> createState() => _GovtCompliancePageState();
}

class _GovtCompliancePageState extends ConsumerState<GovtCompliancePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedHospitalId;
  double _complianceScore = 85.0;
  String _hospitalStatus = 'Licensed';
  String _remarks = '';

  void _submitAudit() async {
    if (_formKey.currentState!.validate() && _selectedHospitalId != null) {
      _formKey.currentState!.save();

      await ref.read(govtHospitalRegistryProvider.notifier).auditHospital(
        facilityId: _selectedHospitalId!,
        score: double.parse(_complianceScore.toStringAsFixed(1)),
        status: _hospitalStatus,
        comment: _remarks,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hospital audit report submitted successfully!', style: GoogleFonts.inter()),
            backgroundColor: AppColors.success,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedHospitalId = null;
          _complianceScore = 85.0;
          _hospitalStatus = 'Licensed';
        });
      }
    } else if (_selectedHospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a facility to audit.', style: GoogleFonts.inter()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = ref.watch(govtHospitalRegistryProvider);
    final auditLogs = ref.watch(govtAuditLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildAuditForm(hospitals),
                        const SizedBox(height: 24),
                        _buildHospitalsComplianceGrid(hospitals),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: _buildAuditLogsExplorer(auditLogs),
                  ),
                ],
              ),
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
                'Regulatory Audits & Compliance Center',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Evaluates clinical standards compliance, issues warnings, manages facility status, and reviews ecosystem action logs.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditForm(List<HospitalProfile> hospitals) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conduct Quality & License Audit',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Hospital Facility', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedHospitalId,
                  decoration: _dropdownInputDecoration(),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                  hint: Text('Select clinical facility to inspect...', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
                  items: hospitals.map((h) {
                    return DropdownMenuItem(
                      value: h.facilityId,
                      child: Text('${h.name} (${h.division})'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedHospitalId = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compliance Score (${_complianceScore.toStringAsFixed(0)}%)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      Slider(
                        value: _complianceScore,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.divider,
                        onChanged: (val) {
                          setState(() {
                            _complianceScore = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Licensing Status', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _hospitalStatus,
                        decoration: _dropdownInputDecoration(),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                        items: ['Licensed', 'Under Review', 'Suspended'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (v) => setState(() => _hospitalStatus = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Audit Findings & Action Remarks',
              hint: 'e.g. Verified ICU bed compliance, clinical code violations resolved, oxygen storage standards met.',
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Remarks are required for audit reporting' : null,
              onSaved: (v) => _remarks = v!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitAudit,
                icon: const Icon(Icons.gavel_rounded, size: 20),
                label: Text('Record Audit & Update License', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsComplianceGrid(List<HospitalProfile> hospitals) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Compliance Roster',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hospitals.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.divider),
            itemBuilder: (context, index) {
              final h = hospitals[index];
              Color scoreColor = AppColors.success;
              if (h.complianceScore < 70.0) {
                scoreColor = AppColors.danger;
              } else if (h.complianceScore < 85.0) {
                scoreColor = AppColors.warning;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('ID: ${h.facilityId} • ${h.classification} Care', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(Icons.shield_rounded, color: scoreColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${h.complianceScore}% Score',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: scoreColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: h.status == 'Licensed'
                            ? AppColors.successLight
                            : (h.status == 'Suspended' ? AppColors.dangerLight : AppColors.warningLight),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        h.status,
                        style: GoogleFonts.inter(
                          color: h.status == 'Licensed'
                              ? AppColors.success
                              : (h.status == 'Suspended' ? AppColors.danger : AppColors.warning),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
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

  Widget _buildAuditLogsExplorer(List<dynamic> logs) {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Ecosystem Audit Trail',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dynamic cryptographic log explorer tracing government registry amendments.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text('No log records.', style: GoogleFonts.inter(color: AppColors.textMuted)))
                : ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      Color statusColor = AppColors.info;
                      Color statusBg = AppColors.infoLight;
                      if (log.status == 'danger') {
                        statusColor = AppColors.danger;
                        statusBg = AppColors.dangerLight;
                      } else if (log.status == 'warning') {
                        statusColor = AppColors.warning;
                        statusBg = AppColors.warningLight;
                      } else if (log.status == 'success') {
                        statusColor = AppColors.success;
                        statusBg = AppColors.successLight;
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    log.action,
                                    style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                Text(log.timestamp, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Target: ${log.target}', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(log.description, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text('Auditor: ${log.operator}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
                              ],
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

  Widget _buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13),
          validator: validator,
          onSaved: onSaved,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ],
    );
  }

  InputDecoration _dropdownInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
