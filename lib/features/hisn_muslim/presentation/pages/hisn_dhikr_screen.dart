
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/hisn_chapter.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';

class HisnDhikrScreen extends StatefulWidget {
  final HisnChapter chapter;

  const HisnDhikrScreen({super.key, required this.chapter});

  @override
  State<HisnDhikrScreen> createState() => _HisnDhikrScreenState();
}

class _HisnDhikrScreenState extends State<HisnDhikrScreen> {
  bool _showTranslation = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingIndex;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      if (_playingIndex == index) {
        await _audioPlayer.stop();
        setState(() => _playingIndex = null);
      } else {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() => _playingIndex = index);
        
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _playingIndex = null);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          IconButton(
            icon: Icon(_showTranslation ? Icons.translate : Icons.translate_outlined),
            tooltip: 'Toggle Translation',
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.chapter.dhikrs.length,
        itemBuilder: (context, index) {
          final dhikr = widget.chapter.dhikrs[index];
          final isPlaying = _playingIndex == index;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor,
                        child: Text(
                          '${dhikr.repeat}',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      if (dhikr.audio.isNotEmpty)
                        IconButton(
                          icon: Icon(isPlaying ? Icons.stop : Icons.volume_up),
                          onPressed: () => _playAudio(dhikr.audio, index),
                          color: AppColors.primaryColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dhikr.arabicText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Othmani', // Assuming Othmani font is available
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_showTranslation && dhikr.translatedText.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      dhikr.translatedText,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
