import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SearchDoctorsPage extends StatelessWidget {
  const SearchDoctorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebar,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Search Doctors',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              'Public Doctor Directory',
              style: GoogleFonts.outfit(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Search integration coming soon. Find specialized doctors across the national network.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
