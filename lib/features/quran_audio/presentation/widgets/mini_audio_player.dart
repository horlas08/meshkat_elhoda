import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranAudioBloc, QuranAudioState>(
      builder: (context, state) {
        if (state is! AudioPlayerPlaying && state is! AudioPlayerPaused) {
          return const SizedBox.shrink();
        }

        final currentState = state as dynamic;
        final track = currentState.track;
        final isPlaying = state is AudioPlayerPlaying;
        final position = currentState.position as Duration?;
        final duration = currentState.duration as Duration?;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.goldenColor.withOpacity(0.8),
                AppColors.goldenColor.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldenColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Song info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.surahName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.reciterName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play/Pause button
                    IconButton(
                      onPressed: () {
                        if (isPlaying) {
                          context.read<QuranAudioBloc>().add(
                            const PauseAudioEvent(),
                          );
                        } else {
                          context.read<QuranAudioBloc>().add(
                            const ResumeAudioEvent(),
                          );
                        }
                      },
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: duration != null && duration!.inMilliseconds > 0
                        ? (position?.inMilliseconds ?? 0) /
                              duration!.inMilliseconds
                        : 0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                // Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position ?? Duration.zero),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _formatDuration(duration ?? Duration.zero),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
