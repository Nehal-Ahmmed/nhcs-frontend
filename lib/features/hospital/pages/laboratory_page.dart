import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/lab_test_order.dart';
import '../presentation/providers/hospital_providers.dart';

class LaboratoryPage extends ConsumerStatefulWidget {
  const LaboratoryPage({super.key});

  @override
  ConsumerState<LaboratoryPage> createState() => _LaboratoryPageState();
}

class _LaboratoryPageState extends ConsumerState<LaboratoryPage> {

  void _nextStage(LabTestOrder order) {
    if (order.status == 'Processing') {
      _showResultEntryDialog(order);
    } else {
      ref.read(laboratoryQueueProvider.notifier).advanceStage(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${order.id} advanced.')),
      );
    }
  }

  void _submitResults(String orderId, Map<String, String> results) {
    ref.read(laboratoryQueueProvider.notifier).advanceStage(orderId, results: results);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Results submitted for $orderId. Awaiting senior verification.'),
        backgroundColor: AppColors.success,
      ),
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
          _buildWorkloadStats(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn('Ordered', Icons.assignment_rounded, AppColors.info),
                  _buildKanbanColumn('Sample Collected', Icons.biotech_rounded, AppColors.accent),
                  _buildKanbanColumn('Processing', Icons.sync_rounded, AppColors.warning),
                  _buildKanbanColumn('Verified', Icons.verified_rounded, AppColors.success),
                  _buildKanbanColumn('Published', Icons.check_circle_rounded, AppColors.primary),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laboratory Operations',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Track and enter diagnostic results from collection to digital publication.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadStats() {
    final labOrders = ref.watch(laboratoryQueueProvider);
    final ordered = labOrders.where((o) => o.status == 'Ordered').length;
    final processing = labOrders.where((o) => o.status == 'Processing' || o.status == 'Sample Collected').length;
    final verified = labOrders.where((o) => o.status == 'Verified').length;
    final completed = labOrders.where((o) => o.status == 'Published').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          _statMini('Pending Orders', ordered.toString(), AppColors.info),
          _statDivider(),
          _statMini('In Lab Processing', processing.toString(), AppColors.warning),
          _statDivider(),
          _statMini('Awaiting Verification', verified.toString(), AppColors.accent),
          _statDivider(),
          _statMini('Published Today', completed.toString(), AppColors.success),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _statDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(width: 1, height: 16, color: AppColors.divider),
    );
  }

  Widget _buildKanbanColumn(String status, IconData icon, Color color) {
    final labOrders = ref.watch(laboratoryQueueProvider);
    final list = labOrders.where((o) => o.status == status).toList();

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(status, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(list.length.toString(), style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('No orders in this column', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = list[index];
                      return _buildKanbanCard(order, color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(LabTestOrder order, Color themeColor) {
    final String status = order.status;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMuted),
              ),
              if (order.results.isNotEmpty)
                const Icon(Icons.description_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.test,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Patient: ${order.patient}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            'Dr: ${order.doctor}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actions',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
              if (status != 'Published')
                InkWell(
                  onTap: () => _nextStage(order),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          status == 'Processing' ? 'Enter' : 'Advance',
                          style: GoogleFonts.inter(color: themeColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 10, color: themeColor),
                      ],
                    ),
                  ),
                )
              else
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  void _showResultEntryDialog(LabTestOrder order) {
    final keyCont = TextEditingController(text: 'Hemoglobin');
    final valCont = TextEditingController(text: '14.2 g/dL');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Lab Results (${order.id})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Test: ${order.test}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Patient: ${order.patient}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: keyCont,
                decoration: const InputDecoration(labelText: 'Parameter / Biomarker'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valCont,
                decoration: const InputDecoration(labelText: 'Measured Value'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simulate PDF Upload', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Report is uploaded to MinIO storage', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ],
                ),
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
                if (keyCont.text.isNotEmpty && valCont.text.isNotEmpty) {
                  _submitResults(order.id, {keyCont.text: valCont.text});
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit & Send to Verification'),
            ),
          ],
        );
      },
    );
  }
}
