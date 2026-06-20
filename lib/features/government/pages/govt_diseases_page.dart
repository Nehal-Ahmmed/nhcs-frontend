import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_insight_panel.dart';
import '../presentation/providers/govt_providers.dart';

class GovtDiseasesPage extends ConsumerStatefulWidget {
  const GovtDiseasesPage({super.key});

  @override
  ConsumerState<GovtDiseasesPage> createState() => _GovtDiseasesPageState();
}

class _GovtDiseasesPageState extends ConsumerState<GovtDiseasesPage> {
  final _formKey = GlobalKey<FormState>();
  String _diseaseName = '';
  String _alertTitle = '';
  String _description = '';
  String _riskLevel = 'High';
  String _division = 'Dhaka';

  void _submitAlert() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      await ref.read(govtDashboardStatsProvider.notifier).issueOutbreakAlert(
        diseaseName: _diseaseName,
        title: _alertTitle,
        description: _description,
        riskLevel: _riskLevel,
        division: _division,
      );

      // Refresh registries/audits list
      ref.read(govtAuditLogsProvider.notifier).loadLogs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('National Health Alert for $_diseaseName declared successfully!', style: GoogleFonts.inter()),
            backgroundColor: AppColors.success,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _riskLevel = 'High';
          _division = 'Dhaka';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(govtDashboardStatsProvider);

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
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDiseaseList(stats),
                        const SizedBox(height: 24),
                        _buildAlertForm(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const AiInsightPanel(
                          title: 'Outbreak Threat Vector Forecast',
                          description: 'Epidemiological models indicate high probability (84% confidence) of a Dengue outbreak expanding from Dhaka North to neighboring regions in the next 14 days due to rainfall patterns and density thresholds.',
                          type: 'danger',
                          recommendations: [
                            'Deploy immediate Vector Control Taskforce to Dhaka North containment zones.',
                            'Initiate diagnostic kit distribution (NS1 antigen tests) to all regional government health centers.',
                            'Broadcast health warnings and advisory campaigns via civic outreach channels.'
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildTrendChartCard(),
                        const SizedBox(height: 24),
                        _buildSurveillanceGuidelines(),
                      ],
                    ),
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
                'National Disease Intelligence & Outbreak Surveillance',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time epidemiological monitoring, threat assessment, and emergency alert declarations.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseList(var stats) {
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
            'Outbreak Monitoring Directory',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.outbreaks.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.divider),
            itemBuilder: (context, index) {
              final o = stats.outbreaks[index];
              Color riskColor = AppColors.success;
              Color riskBg = AppColors.successLight;
              if (o.riskLevel == 'High') {
                riskColor = AppColors.danger;
                riskBg = AppColors.dangerLight;
              } else if (o.riskLevel == 'Moderate') {
                riskColor = AppColors.warning;
                riskBg = AppColors.warningLight;
              }

              IconData trendIcon = Icons.trending_flat_rounded;
              Color trendColor = AppColors.textMuted;
              if (o.trend == 'Rising') {
                trendIcon = Icons.trending_up_rounded;
                trendColor = AppColors.danger;
              } else if (o.trend == 'Falling') {
                trendIcon = Icons.trending_down_rounded;
                trendColor = AppColors.success;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.diseaseName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Affected divisions: ${o.affectedAreas}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${o.activeCases} Active', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('+${o.weeklyNewCases} this week', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: riskBg, borderRadius: BorderRadius.circular(6)),
                      child: Text('${o.riskLevel} Risk', style: GoogleFonts.inter(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, color: trendColor, size: 20),
                        const SizedBox(width: 4),
                        Text(o.trend, style: GoogleFonts.inter(color: trendColor, fontWeight: FontWeight.w500, fontSize: 13)),
                      ],
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

  Widget _buildAlertForm() {
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
              'Declare National Health Alert',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Disease / Agent Name',
                    hint: 'e.g. Dengue Virus, Cholera, etc.',
                    validator: (v) => v == null || v.isEmpty ? 'Disease name is required' : null,
                    onSaved: (v) => _diseaseName = v!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Alert Title',
                    hint: 'e.g. Outbreak Level Surge',
                    validator: (v) => v == null || v.isEmpty ? 'Alert title is required' : null,
                    onSaved: (v) => _alertTitle = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Alert Description & Advisory Remarks',
              hint: 'Provide instructions for hospitals and citizen advisory details...',
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
              onSaved: (v) => _description = v!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Risk Assessment Category', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _riskLevel,
                        decoration: _dropdownInputDecoration(),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                        items: ['High', 'Moderate', 'Low'].map((r) {
                          return DropdownMenuItem(value: r, child: Text('$r Risk'));
                        }).toList(),
                        onChanged: (v) => setState(() => _riskLevel = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Affected Division', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _division,
                        decoration: _dropdownInputDecoration(),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                        items: ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna', 'Barisal', 'Mymensingh', 'Rangpur'].map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (v) => setState(() => _division = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitAlert,
                icon: const Icon(Icons.campaign_rounded, size: 20),
                label: Text('Publish Emergency Alert', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
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

  Widget _buildTrendChartCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dengue Surveillance Analytics',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Infections trend (Weekly aggregates)',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(6)),
                child: Text('Surging (Dhaka)', style: GoogleFonts.inter(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _OutbreakChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chartLabel('Week 20'),
              _chartLabel('Week 21'),
              _chartLabel('Week 22'),
              _chartLabel('Week 23'),
              _chartLabel('Week 24 (Current)'),
            ],
          )
        ],
      ),
    );
  }

  Widget _chartLabel(String text) {
    return Text(text, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11));
  }

  Widget _buildSurveillanceGuidelines() {
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
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Clinical Surveillance Directives',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _guidelineItem('1. Mandate all local hospitals to report fever cases within 12 hours.'),
          _guidelineItem('2. Enforce strict quarantine procedures if outbreak risk indices turn Critical.'),
          _guidelineItem('3. Conduct localized fogging and mosquito larvae inspections in Dhaka South/North areas.'),
          _guidelineItem('4. Reserve at least 15% of bed capacities in regional hospitals for Dengue isolation wards.'),
        ],
      ),
    );
  }

  Widget _guidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
      ),
    );
  }
}

class _OutbreakChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw Grid Lines
    final Paint gridPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepY = height / 4;
    for (int i = 0; i <= 4; i++) {
      final double y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Weekly aggregate trend data (Week 20 to 24)
    final List<double> dataPoints = [0.15, 0.22, 0.40, 0.65, 0.88];

    final double stepX = width / (dataPoints.length - 1);
    final Path path = Path();
    final Path areaPath = Path();

    final Paint linePaint = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.danger.withOpacity(0.25), AppColors.danger.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, width, height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      final double y = height - (dataPoints[i] * height * 0.8) - 10;

      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }

      if (i == dataPoints.length - 1) {
        areaPath.lineTo(x, height);
        areaPath.close();
      }
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw point markers
    final Paint pointPaint = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.fill;

    final Paint whiteCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      final double y = height - (dataPoints[i] * height * 0.8) - 10;
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      canvas.drawCircle(Offset(x, y), 2.5, whiteCore);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
