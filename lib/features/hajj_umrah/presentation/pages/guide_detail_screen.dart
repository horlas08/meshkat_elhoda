import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/domain/entities/guide_step.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/bloc/hajj_umrah_cubit.dart';
import 'package:share_plus/share_plus.dart';

class GuideDetailScreen extends StatelessWidget {
  final GuideStep step;
  final String guideType;

  const GuideDetailScreen({
    super.key, 
    required this.step,
    required this.guideType,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(step.getTitle(lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  step.getDescription(lang),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Duas Section
            if (step.duas.isNotEmpty) ...[
              const Text(
                "Supplications / أدعية",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...step.duas.map((dua) => _buildDuaCard(context, dua, lang)),
            ],

            const SizedBox(height: 32),
            
            // Complete Button
            ElevatedButton.icon(
              onPressed: () {
                context.read<HajjUmrahCubit>().markStepComplete(guideType, step.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stage Completed ✅')),
                );
                Navigator.pop(context); // Go back to list
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Stage Completed / إتمام المناسك"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard(BuildContext context, GuideDua dua, String lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (dua.getTitle(lang).isNotEmpty)
              Text(
                dua.getTitle(lang),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            const SizedBox(height: 8),
            Text(
              dua.arabic,
              style: const TextStyle(
                fontFamily: 'Othmani', // Assuming this font exists
                fontSize: 22,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const Divider(height: 24),
            Text(
              dua.getTranslation(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: "${dua.arabic}\n\n${dua.getTranslation(lang)}"));
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Copied")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share("${dua.arabic}\n\n${dua.getTranslation(lang)}\n\nvia Meshkat Elhoda");
                  },
                ),
                // Audio button (Optional, if we have URLs)
              ],
            )
          ],
        ),
      ),
    );
  }
}
