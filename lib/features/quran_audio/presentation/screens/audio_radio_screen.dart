import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/audio_player/audio_player_service.dart';
import 'package:meshkat_elhoda/core/services/quran_audio_services.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/radio_station.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AudioRadioScreen extends StatefulWidget {
  const AudioRadioScreen({Key? key}) : super(key: key);

  @override
  State<AudioRadioScreen> createState() => _AudioRadioScreenState();
}

class _AudioRadioScreenState extends State<AudioRadioScreen> {
  late AudioPlayerService _audioPlayerService;
  late QuranAudioService _quranAudioService;
  late ValueNotifier<String?> _currentStationIdNotifier;

  @override
  void initState() {
    super.initState();
    _audioPlayerService = AudioPlayerService();
    _quranAudioService = QuranAudioService();
    _currentStationIdNotifier = ValueNotifier<String?>(null);
    _initializeAudioService();
    // Load radio stations when screen initializes
    context.read<QuranAudioBloc>().add(const LoadRadioStationsEvent());
  }

  Future<void> _initializeAudioService() async {
    try {
      if (!_audioPlayerService.isInitialized) {
        await _audioPlayerService.initialize();
      }
    } catch (e) {
      log('❌ Error initializing audio service: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayerService.stop();
    _currentStationIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.quranRadio,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: BlocBuilder<QuranAudioBloc, QuranAudioState>(
        builder: (context, state) {
          if (state is RadioStationsLoading) {
            return const Center(child: QuranLottieLoading());
          }

          if (state is RadioStationsError) {
            log(state.message);
            return Center(
              child: Text(state.message, textAlign: TextAlign.center),
            );
          }

          if (state is RadioStationsLoaded) {
            final stations = state.stations;

            if (stations.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noStationsAvailable),
              );
            }

            return ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return RadioStationCard(
                  station: station,
                  audioPlayerService: _audioPlayerService,
                  currentStationIdNotifier: _currentStationIdNotifier,
                  onPlay: _playRadioStream,
                  onPause: _pauseRadioStream,
                  onResume: _resumeRadioStream,
                  onStop: _stopRadioStream,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _playRadioStream(RadioStation station) async {
    try {
      log('📻 Starting radio stream: ${station.name}');
      _currentStationIdNotifier.value = station.id;

      // إنشاء audio track للراديو
      final radioTrack = AudioTrack(
        surahNumber: station.id,
        surahName: station.name,
        reciterName: station.name,
        audioUrl: station.url,
        ayahCount: 0,
      );

      // تشغيل البث في الخلفية باستخدام QuranAudioService
      await _quranAudioService.loadAyah(
        audioUrl: station.url,
        ayahText: station.name,
        surahName: station.name,
        ayahNumber: 1,
      );

      // تشغيل الصوت محلياً أيضاً
      await _audioPlayerService.playTrack(radioTrack);
      log('▶️ Radio stream playing: ${station.name}');
    } catch (e) {
      log('❌ Error playing radio stream: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pauseRadioStream() async {
    try {
      await _audioPlayerService.pause();
      await _quranAudioService.pause();
      log('⏸️ Radio stream paused');
    } catch (e) {
      log('❌ Error pausing radio stream: $e');
    }
  }

  Future<void> _resumeRadioStream() async {
    try {
      await _audioPlayerService.resume();
      await _quranAudioService.play();
      log('▶️ Radio stream resumed');
    } catch (e) {
      log('❌ Error resuming radio stream: $e');
    }
  }

  Future<void> _stopRadioStream() async {
    try {
      await _audioPlayerService.stop();
      await _quranAudioService.stop();
      _currentStationIdNotifier.value = null;
      log('⏹️ Radio stream stopped');
    } catch (e) {
      log('❌ Error stopping radio stream: $e');
    }
  }
}

class RadioStationCard extends StatefulWidget {
  final RadioStation station;
  final Future<void> Function(RadioStation) onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onResume;
  final Future<void> Function() onStop;
  final AudioPlayerService audioPlayerService;
  final ValueNotifier<String?> currentStationIdNotifier;

  const RadioStationCard({
    Key? key,
    required this.station,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.audioPlayerService,
    required this.currentStationIdNotifier,
  }) : super(key: key);

  @override
  State<RadioStationCard> createState() => _RadioStationCardState();
}

class _RadioStationCardState extends State<RadioStationCard> {
  bool _isPlaying = false;
  bool _isCurrentStation = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // ✅ الاستماع للمحطة الحالية فقط (هذا هو المصدر الموثوق)
    widget.currentStationIdNotifier.addListener(_onCurrentStationChanged);
  }

  void _onCurrentStationChanged() {
    if (mounted) {
      final isCurrent =
          widget.currentStationIdNotifier.value == widget.station.id;
      setState(() {
        _isCurrentStation = isCurrent;
        // ✅ إذا لم تكن المحطة الحالية، أوقف تشغيل الأيقونة فوراً
        if (!isCurrent) {
          _isPlaying = false;
        }
      });
    }
  }

  @override
  void dispose() {
    widget.currentStationIdNotifier.removeListener(_onCurrentStationChanged);
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!widget.station.isActive) return;

    if (_isCurrentStation && _isPlaying) {
      // إيقاف مؤقت
      await widget.onPause();
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    } else if (_isCurrentStation && !_isPlaying) {
      // استئناف
      await widget.onResume();
      if (mounted) {
        setState(() => _isPlaying = true);
      }
    } else {
      // تشغيل محطة جديدة
      // ✅ أوقف البث الحالي
      await widget.onStop();

      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isCurrentStation = true;
        });
        // ✅ حدّث المؤشر لتخبير بقية الـ cards
        widget.currentStationIdNotifier.value = widget.station.id;
        // ✅ شغل المحطة بعد تحديث الحالة
        await widget.onPlay(widget.station);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Station icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.radio_rounded, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 12),
            // Station info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.station.name,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.station.description != null &&
                      widget.station.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.station.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.station.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.station.isActive
                            ? AppLocalizations.of(context)!.liveRadio
                            : AppLocalizations.of(context)!.offlineRadio,
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.station.isActive
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Play/Pause button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePlayback,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (_isCurrentStation)
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    (_isCurrentStation && _isPlaying)
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.blue,
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
