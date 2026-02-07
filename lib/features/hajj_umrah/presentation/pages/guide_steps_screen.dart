import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/bloc/hajj_umrah_cubit.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/pages/guide_detail_screen.dart';

class GuideStepsScreen extends StatelessWidget {
  final String title;
  const GuideStepsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<HajjUmrahCubit, HajjUmrahState>(
        builder: (context, state) {
          if (state is HajjUmrahLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HajjUmrahError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is HajjUmrahLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.steps.length,
              itemBuilder: (context, index) {
                final step = state.steps[index];
                return _buildStepCard(context, step, index, state.lastCompletedId);
              },
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, GuideStep step, int index, String? lastCompletedId) {
    // Determine if step is completed (simple logic: all previous are complete if this one is, 
    // but here we just track THE last completed one.
    // Better logic: if index <= indexOf(lastCompletedId)
    // We need to pass the full list to find index of lastCompletedId.
    // Let's assume passed ID is enough for strict "Check Mark".
    
    final isCompleted = step.id == lastCompletedId; // This is strictly "Is this the last one?"
    // To show "All previous checked", we need index comparison.
    // But since list is ordered, we can do this in Bloc or here.
    // Let's rely on simple highlight for now.
    
    final lang = Localizations.localeOf(context).languageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : null,
          child: Text("${index + 1}"),
        ),
        title: Text(step.getTitle(lang)),
        subtitle: Text(
          step.getDescription(lang), 
          maxLines: 2, 
          overflow: TextOverflow.ellipsis
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GuideDetailScreen(step: step, guideType: (context.read<HajjUmrahCubit>().state as HajjUmrahLoaded).type),
            ),
          );
        },
      ),
    );
  }
}
