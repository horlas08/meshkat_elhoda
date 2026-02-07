import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/bloc/hajj_umrah_cubit.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/pages/guide_steps_screen.dart';

class HajjUmrahHomeScreen extends StatelessWidget {
  const HajjUmrahHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل الحج والعمرة'),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              context,
              title: "مناسك العمرة",
              icon: Icons.refresh, // Replace with proper icon
              onTap: () {
                context.read<HajjUmrahCubit>().loadUmrahGuide();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuideStepsScreen(title: "مناسك العمرة")),
                );
              },
            ),
            const SizedBox(height: 16),
             _buildCard(
              context,
              title: "مناسك الحج",
              icon: Icons.mosque,
              onTap: () {
                context.read<HajjUmrahCubit>().loadHajjGuide();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuideStepsScreen(title: "مناسك الحج")),
                );
              },
            ),
            const SizedBox(height: 24),
            // "My Journey" Section ?
            // For now, progress is integrated into steps list.
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
