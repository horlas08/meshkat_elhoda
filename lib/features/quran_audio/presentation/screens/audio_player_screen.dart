import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/services/quran_audio_services.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/audio_track.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/reciter.dart';
import 'package:meshkat_elhoda/features/quran_audio/domain/entities/surah.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/surah_download_cubit.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/surah_download_state.dart';

class AudioPlayerScreen extends StatefulWidget {
  final List<AudioTrack> playlist;
  final int startIndex;

  const AudioPlayerScreen({
    Key? key,
    required this.playlist,
    this.startIndex = 0,
  }) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late int _currentIndex;
  final QuranAudioService _audioService = QuranAudioService();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isLoaded = false;
  bool _isCompleted = false;
  bool _isSeeking = false;

  Duration _position = Duration.zero;
  Duration? _duration;

  StreamSubscription? _playbackSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _initializeAudio();
  }

  void _initializeAudio() async {
    print(
      '🚀 Initializing audio for track: ${widget.playlist[_currentIndex].surahName}',
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isLoaded = false;
        _isCompleted = false;
        _position = Duration.zero;
        _duration = null;
      });
    }

    try {
      final track = widget.playlist[_currentIndex];
      print('📥 Loading: ${track.audioUrl}');

      await _audioService.loadAyah(
        audioUrl: track.audioUrl,
        ayahText: track.surahName,
        surahName: track.surahName,
        ayahNumber: int.tryParse(track.surahNumber) ?? 1,
      );

      // إلغاء الـ subscriptions القديمة وإعادة تشغيلها
      _playbackSubscription?.cancel();
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();

      print('🔄 Setting up new listeners...');
      _setupListeners();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoaded = true;
        });
      }
      print('✅ Audio initialized successfully');
    } catch (e) {
      print('❌ Error initializing audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isLoaded = false;
        });
      }
    }
  }

  void _setupListeners() {
    _playbackSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();

    print('🔌 Setting up listeners...');

    _playbackSubscription = _audioService.playbackState.listen((state) {
      print(
        '🎵 Playback state: playing=${state.playing}, processingState=${state.processingState}, updatePosition=${state.updatePosition}',
      );
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isCompleted =
              state.processingState == AudioProcessingState.completed;
        });
      }
    });

    _positionSubscription = _audioService.position.listen(
      (position) {
        print('⏱️ Position from stream: $position');
        if (!_isSeeking && mounted) {
          setState(() {
            _position = position;
          });
        }
      },
      onError: (error) {
        print('❌ Position stream error: $error');
      },
    );

    _durationSubscription = _audioService.duration.listen(
      (duration) {
        print('📊 Duration from stream: $duration');
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      },
      onError: (error) {
        print('❌ Duration stream error: $error');
      },
    );

    print('✅ All listeners set up');
  }

  void _playPause() {
    if (!_isLoaded) return;

    if (_isCompleted) {
      _audioService.replay();
    } else if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.play();
    }
  }

  void _playNext() {
    if (_currentIndex < widget.playlist.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initializeAudio();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initializeAudio();
    }
  }

  void _replay() {
    _audioService.replay();
  }

  void _seekToPosition(double value) {
    if (_duration == null || _duration!.inSeconds == 0) {
      print('❌ Cannot seek: duration=$_duration');
      return;
    }

    final newPosition = Duration(
      seconds: (value * _duration!.inSeconds).toInt(),
    );

    print('🔍 Seeking to: $newPosition (value=$value, duration=$_duration)');

    setState(() {
      _isSeeking = true;
      _position = newPosition;
    });

    _audioService
        .seek(newPosition)
        .then((_) {
          print('✅ Seek completed to: $newPosition');
          if (mounted) {
            setState(() {
              _isSeeking = false;
            });
          }
        })
        .catchError((error) {
          print('❌ Seek error: $error');
          if (mounted) {
            setState(() {
              _isSeeking = false;
            });
          }
        });
  }

  void _skipForward() {
    print('⏩ Skip forward called - Duration: $_duration, Position: $_position');

    if (_duration == null) {
      print('❌ Duration is null, cannot skip forward');
      return;
    }

    if (_duration!.inSeconds <= 0) {
      print('❌ Duration is ${_duration!.inSeconds}s, cannot skip forward');
      return;
    }

    final newPosition = _position + const Duration(seconds: 10);
    final maxPosition = _duration!;

    final targetPosition = newPosition > maxPosition
        ? maxPosition
        : newPosition;

    print(
      '✅ Skip forward: $_position + 10s -> $targetPosition (max: $maxPosition)',
    );
    _audioService.seek(targetPosition);
  }

  void _skipBackward() {
    print(
      '⏪ Skip backward called - Duration: $_duration, Position: $_position',
    );

    if (_duration == null) {
      print('❌ Duration is null, cannot skip backward');
      return;
    }

    if (_duration!.inSeconds <= 0) {
      print('❌ Duration is ${_duration!.inSeconds}s, cannot skip backward');
      return;
    }

    final newPosition = _position - const Duration(seconds: 10);

    final targetPosition = newPosition < Duration.zero
        ? Duration.zero
        : newPosition;

    print('✅ Skip backward: $_position - 10s -> $targetPosition');
    _audioService.seek(targetPosition);
  }

  void _retry() {
    _initializeAudio();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getButtonIcon() {
    if (_isCompleted) return Icons.replay_circle_filled_outlined;
    if (_isPlaying) return Icons.pause_circle_filled;
    return Icons.play_circle_filled;
  }

  Color _getButtonColor() {
    if (!_isLoaded) return Colors.grey;
    return AppColors.goldenColor;
  }

  double _getProgressValue() {
    if (_duration == null || _duration!.inSeconds == 0) return 0.0;
    return _position.inSeconds / _duration!.inSeconds;
  }

  @override
  void dispose() {
    _playbackSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final currentTrack = widget.playlist[_currentIndex];

    String _getButtonText() {
      if (_isCompleted) return isArabic ? 'إعادة التشغيل' : 'Replay';
      if (_isPlaying) return isArabic ? 'إيقاف' : 'Pause';
      return isArabic ? 'تشغيل' : 'Play';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مشغل الصوت' : 'Audio Player'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          BlocProvider(
            create: (context) => getIt<SurahDownloadCubit>(),
            child: BlocConsumer<SurahDownloadCubit, SurahDownloadState>(
              listener: (context, state) {
                if (state is SurahDownloadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic
                            ? 'تم التحميل بنجاح'
                            : 'Downloaded successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is SurahDownloadError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SurahDownloadLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (state is SurahDownloadSuccess) {
                  return const IconButton(
                    icon: Icon(Icons.check_circle_outline),
                    onPressed: null, // Disable if downloaded in this session
                  );
                }

                return IconButton(
                  icon: const Icon(Icons.download_rounded),
                  tooltip: isArabic ? 'تحميل' : 'Download',
                  onPressed: () {
                    log("Download button pressed");
                    final track = widget.playlist[_currentIndex];

                    // Check if it's a local file
                    if (!track.audioUrl.startsWith('http')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'الملف محمل بالفعل'
                                : 'File already downloaded',
                          ),
                        ),
                      );
                      return;
                    }

                    // Extract server from URL
                    final lastSlashIndex = track.audioUrl.lastIndexOf('/');
                    final server = track.audioUrl.substring(0, lastSlashIndex);

                    // Create Surah object
                    final surah = Surah(
                      number: int.parse(track.surahNumber),
                      name: track.surahName,
                      nameEnglish: '',
                      nameArabic: track.surahName,
                      ayahCount: track.ayahCount,
                      type: 'Meccan',
                    );

                    // Create Reciter object
                    final reciter = Reciter(
                      id: '0',
                      name: track.reciterName,
                      server: server,
                      rewaya: '',
                      count: 0,
                      letter: '',
                      suras: '',
                    );

                    log(
                      "Starting download for: ${surah.name} by ${reciter.name}",
                    );

                    // Trigger download
                    context.read<SurahDownloadCubit>().download(surah, reciter);
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Album Art / Icon
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldenColor,
                      AppColors.goldenColor.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldenColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading && _isLoaded == false
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.music_note_rounded,
                          size: 120,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // Song Title and Artist
              Text(
                currentTrack.surahName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentTrack.reciterName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Error State
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isArabic ? 'خطأ في تحميل الصوت' : 'Audio loading error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _retry,
                        child: Text(isArabic ? 'إعادة محاولة' : 'Retry'),
                      ),
                    ],
                  ),
                )
              else if (_isLoading && !_isLoaded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.goldenColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(isArabic ? 'جاري التحميل...' : 'Loading audio...'),
                    ],
                  ),
                )
              else ...[
                // Progress Bar
                Column(
                  children: [
                    Slider(
                      value: _getProgressValue().clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      onChanged: _isLoaded ? _seekToPosition : null,
                      onChangeStart: (_) => setState(() => _isSeeking = true),
                      onChangeEnd: (_) => setState(() => _isSeeking = false),
                      activeColor: AppColors.goldenColor,
                      inactiveColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _duration != null
                              ? _formatDuration(_duration!)
                              : '--:--',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // شريط التحكم السريع (تقديم 15 ثانية للخلف أو للأمام)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // تأخير 15 ثانية
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldenColor.withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.fast_rewind_rounded),
                            iconSize: 24,
                            color: AppColors.goldenColor,
                            onPressed: _isLoaded ? _skipBackward : null,
                            tooltip: isArabic
                                ? 'تأخير 15 ثانية'
                                : 'Skip back 15s',
                          ),
                        ),
                        const SizedBox(width: 16),
                        // عرض الوقت الحالي
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // تقديم 15 ثانية
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldenColor.withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.fast_forward_rounded),
                            iconSize: 24,
                            color: AppColors.goldenColor,
                            onPressed: _isLoaded ? _skipForward : null,
                            tooltip: isArabic
                                ? 'تقديم 15 ثانية'
                                : 'Skip forward 15s',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                // Main Play/Pause Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldenColor,
                        AppColors.goldenColor.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldenColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(_getButtonIcon(), size: 50),
                    color: Colors.white,
                    onPressed: _isLoaded ? _playPause : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getButtonText(),
                  style: TextStyle(
                    color: _getButtonColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.skip_previous_rounded),
                        iconSize: 28,
                        color: _currentIndex > 0 ? Colors.black : Colors.grey,
                        onPressed: _currentIndex > 0 ? _playPrevious : null,
                      ),
                    ),

                    // Replay
                    IconButton(
                      icon: const Icon(Icons.replay, size: 30),
                      color: AppColors.goldenColor,
                      onPressed: _replay,
                      tooltip: isArabic ? 'إعادة التشغيل' : 'Replay',
                    ),

                    // Next
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.skip_next_rounded),
                        iconSize: 28,
                        color: _currentIndex < widget.playlist.length - 1
                            ? Colors.black
                            : Colors.grey,
                        onPressed: _currentIndex < widget.playlist.length - 1
                            ? _playNext
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Playlist Info
                Text(
                  '${isArabic ? 'السورة' : 'Surah'} ${_currentIndex + 1} ${isArabic ? 'من' : 'of'} ${widget.playlist.length}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                // Current Status
                const SizedBox(height: 16),
                if (_isPlaying || _isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCompleted
                              ? Icons.done_all_rounded
                              : Icons.play_arrow_rounded,
                          size: 16,
                          color: _isCompleted ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCompleted
                              ? (isArabic ? 'انتهى التشغيل' : 'Completed')
                              : (isArabic ? 'جاري التشغيل' : 'Playing'),
                          style: TextStyle(
                            color: _isCompleted ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
