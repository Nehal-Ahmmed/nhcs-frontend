import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../presentation/providers/govt_providers.dart';
import '../data/models/govt_resource_models.dart';

class GovtResourcesPage extends ConsumerWidget {
  const GovtResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(govtResourcesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: resources.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final r = resources[index];
                      return _buildResourceCard(context, r);
                    },
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
                'National Resource Mapping & Division Capacity',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitors regional clinical workforce gaps, ICU resources, ventilator allocations, and oxygen storage capacity.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, RegionalResource r) {
    final occupancyRate = r.totalBeds > 0 ? (r.occupiedBeds / r.totalBeds) : 0.0;
    
    Color gapColor = AppColors.success;
    Color gapBg = AppColors.successLight;
    if (r.workforceGap == 'High') {
      gapColor = AppColors.danger;
      gapBg = AppColors.dangerLight;
    } else if (r.workforceGap == 'Moderate') {
      gapColor = AppColors.warning;
      gapBg = AppColors.warningLight;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r.division,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: gapBg, borderRadius: BorderRadius.circular(6)),
                child: Text('Workforce Deficit: ${r.workforceGap}', style: GoogleFonts.inter(color: gapColor, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                _buildRowInfo('Active Workforce Staff', '${r.activeWorkforce} Personnel', Icons.people_outline_rounded),
                const SizedBox(height: 8),
                _buildRowInfo('Ventilator Inventory', '${r.ventilatorCount} Units', Icons.air_rounded),
                const SizedBox(height: 8),
                _buildRowInfo('Liquid Oxygen Reserve', '${r.oxygenReserves} L', Icons.opacity_rounded),
              ],
            ),
          ),
          const Divider(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bed Occupancy Capacity', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  Text('${r.occupiedBeds} / ${r.totalBeds} occupied', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: occupancyRate,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    occupancyRate > 0.85 ? AppColors.danger : (occupancyRate > 0.70 ? AppColors.warning : AppColors.success),
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
