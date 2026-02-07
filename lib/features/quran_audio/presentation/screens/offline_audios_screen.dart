import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/offline_audios_cubit.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/offline_audios_state.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_player_screen.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class OfflineAudiosScreen extends StatelessWidget {
  const OfflineAudiosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OfflineAudiosCubit>()..loadOfflineAudios(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.downloadedAudio),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<OfflineAudiosCubit, OfflineAudiosState>(
          builder: (context, state) {
            if (state is OfflineAudiosLoading) {
              return const Center(child: QuranLottieLoading());
            } else if (state is OfflineAudiosLoaded) {
              if (state.audios.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noDownloadedAudio,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.audios.length,
                itemBuilder: (context, index) {
                  final audio = state.audios[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.goldenColor.withOpacity(0.1),
                        child: Text(
                          audio.surahNumber.toString(),
                          style: TextStyle(color: AppColors.goldenColor),
                        ),
                      ),
                      title: Text(
                        audio.surahName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(audio.reciterName),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.deleteAudioTitle,
                              ),
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.deleteAudioConfirm,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<OfflineAudiosCubit>()
                                        .deleteAudio(audio.id);
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        // Navigate to AudioPlayerScreen with local path
                        // Ensure path is a valid URI for just_audio
                        // On Windows/Android/iOS, file paths usually need file:// scheme
                        // But just_audio's AudioSource.uri handles it if we pass Uri.file(path)
                        // However, AudioPlayerScreen passes the string to loadAyah which calls AudioSource.uri(Uri.parse(url))
                        // So we should prefix with file:// if it's a raw path.

                        final audioUrl = audio.localPath.startsWith('http')
                            ? audio.localPath
                            : 'file://${audio.localPath}';

                        final track = AudioTrack(
                          surahNumber: audio.surahNumber.toString(),
                          surahName: audio.surahName,
                          reciterName: audio.reciterName,
                          audioUrl: audioUrl,
                          ayahCount: 0,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AudioPlayerScreen(
                              playlist: [track],
                              startIndex: 0,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is OfflineAudiosError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
