import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/services/quran_audio_services.dart';

import '../../../../l10n/app_localizations.dart';

class AudioPlayerDialog extends StatefulWidget {
  final String audioUrl;
  final String ayahText;
  final String surahName;
  final int ayahNumber;

  const AudioPlayerDialog({
    Key? key,
    required this.audioUrl,
    required this.ayahText,
    required this.surahName,
    required this.ayahNumber,
  }) : super(key: key);

  @override
  State<AudioPlayerDialog> createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog> {
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
    _initializeAudio();
  }

  void _initializeAudio() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isLoaded = false;
        _isCompleted = false;
        _position = Duration.zero;
      });
    }

    try {
      await _audioService.loadAyah(
        audioUrl: widget.audioUrl,
        ayahText: widget.ayahText,
        surahName: widget.surahName,
        ayahNumber: widget.ayahNumber,
      );

      _setupListeners();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoaded = true;
        });
      }
    } catch (e) {
      print('Error initializing audio: $e');
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

    _playbackSubscription = _audioService.playbackState.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isCompleted =
              state.processingState == AudioProcessingState.completed;
        });
      }
    });

    _positionSubscription = _audioService.position.listen((position) {
      if (!_isSeeking && mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _durationSubscription = _audioService.duration.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
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

  void _stop() {
    _audioService.stop();
    Navigator.pop(context);
  }

  void _replay() {
    _audioService.replay();
  }

  void _seekToPosition(double value) {
    if (_duration == null) return;

    final newPosition = Duration(
      seconds: (value * _duration!.inSeconds).toInt(),
    );

    setState(() {
      _isSeeking = true;
      _position = newPosition;
    });

    _audioService.seek(newPosition).then((_) {
      if (mounted) {
        setState(() {
          _isSeeking = false;
        });
      }
    });
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
    return const Color(0xFFD4A574);
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
    final localizations = AppLocalizations.of(context);
    String _getButtonText() {
      if (_isCompleted) return localizations?.restart ?? 'Restart';
      if (_isPlaying) return localizations?.stop ?? 'Stop';
      return localizations?.ayahOptionPlay ?? 'Play';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${localizations?.surahLabel ?? 'Surah'} ${widget.surahName} - ${localizations?.ayahLabel ?? 'Ayah'} ${widget.ayahNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4A574),
              ),
            ),
            const SizedBox(height: 16),

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
                      localizations?.audioLoadError ?? 'Audio loading error',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _retry,
                      child: Text(localizations?.retry ?? 'Retry'),
                    ),
                  ],
                ),
              )
            else if (_isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFD4A574),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(localizations?.audioLoading ?? 'Loading audio...'),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      widget.ayahText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        //color: Colors.black87,
                      ),
                    ),
                  ),

                  // Progress Bar
                  if (_duration != null)
                    Column(
                      children: [
                        Slider(
                          value: _getProgressValue().clamp(0.0, 1.0),
                          min: 0.0,
                          max: 1.0,
                          onChanged: _isLoaded ? _seekToPosition : null,
                          onChangeStart: (_) =>
                              setState(() => _isSeeking = true),
                          onChangeEnd: (_) =>
                              setState(() => _isSeeking = false),
                          activeColor: const Color(0xFFD4A574),
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
                              _formatDuration(_duration!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // زر التحكم الرئيسي
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(_getButtonIcon(), size: 50),
                        color: _getButtonColor(),
                        onPressed: _isLoaded ? _playPause : null,
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
                    ],
                  ),

                  // أزرار التحكم الإضافية
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay, size: 30),
                          color: const Color(0xFFD4A574),
                          onPressed: _replay,
                          tooltip: localizations?.restart ?? 'Replay',
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.stop, size: 30),
                          color: Colors.red,
                          onPressed: _stop,
                          tooltip: localizations?.stop ?? 'Stop',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: _stop,
              child: Text(
                localizations?.close ?? 'Close',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
