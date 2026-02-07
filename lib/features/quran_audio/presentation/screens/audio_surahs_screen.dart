import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_player_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AudioSurahsScreen extends StatefulWidget {
  final Reciter reciter;

  const AudioSurahsScreen({Key? key, required this.reciter}) : super(key: key);

  @override
  State<AudioSurahsScreen> createState() => _AudioSurahsScreenState();
}

class _AudioSurahsScreenState extends State<AudioSurahsScreen> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ تحميل السور المرة الأولى فقط
    if (_isFirstLoad) {
      _isFirstLoad = false;
      print('📥 Loading surahs for: ${widget.reciter.name}');
      context.read<QuranAudioBloc>().add(
        LoadSurahsEvent(reciter: widget.reciter),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return WillPopScope(
      onWillPop: () async {
        // ✅ عند الضغط على back، البيانات تبقى محفوظة في Bloc
        print('👈 Popping from AudioSurahsScreen - data remains in Bloc');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.surahs,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.reciter.name, style: TextStyle(fontSize: 12.sp)),
            ],
          ),
        ),
        body: BlocBuilder<QuranAudioBloc, QuranAudioState>(
          buildWhen: (previous, current) {
            // ✅ أعد البناء فقط عند تغيير السور
            return current is SurahsLoading ||
                current is SurahsLoaded ||
                current is SurahsError;
          },
          builder: (context, state) {
            if (state is SurahsLoading) {
              return const Center(child: QuranLottieLoading());
            }

            if (state is SurahsError) {
              return Center(
                child: Text(state.message, textAlign: TextAlign.center),
              );
            }

            if (state is SurahsLoaded) {
              final surahs = state.surahs;

              // Filter surahs based on reciter's available surahs
              final surahNumbers = widget.reciter.suras
                  .split(',')
                  .map((s) => s.trim())
                  .toSet();
              final availableSurahs = surahs
                  .where(
                    (surah) => surahNumbers.contains(surah.number.toString()),
                  )
                  .toList();

              return ListView.builder(
                itemCount: availableSurahs.length,
                itemBuilder: (context, index) {
                  final surah = availableSurahs[index];
                  return SurahCard(
                    surah: surah,
                    reciter: widget.reciter,
                    onPlayTap: () {
                      // Create list of all tracks for playlist
                      final audioTracks = <AudioTrack>[];
                      for (var s in availableSurahs) {
                        final surahNum = s.number.toString().padLeft(3, '0');
                        audioTracks.add(
                          AudioTrack(
                            surahNumber: s.number.toString(),
                            surahName: s.name,
                            reciterName: widget.reciter.name,
                            audioUrl: '${widget.reciter.server}/$surahNum.mp3',
                            ayahCount: s.ayahCount,
                          ),
                        );
                      }

                      final selectedIndex = availableSurahs.indexOf(surah);

                      // ✅ تحميل Playlist وذهاب للمشغل
                      context.read<QuranAudioBloc>().add(
                        LoadPlaylistEvent(
                          playlist: audioTracks,
                          startIndex: selectedIndex,
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerScreen(
                            playlist: audioTracks,
                            startIndex: selectedIndex,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class SurahCard extends StatelessWidget {
  final Surah surah;
  final Reciter reciter;
  final VoidCallback onPlayTap;

  const SurahCard({
    Key? key,
    required this.surah,
    required this.reciter,
    required this.onPlayTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Surah number
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldenColor,
                    AppColors.goldenColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.ayahsCount.replaceAll(
                      '{count}',
                      surah.ayahCount.toString(),
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Play button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPlayTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.goldenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.goldenColor,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
