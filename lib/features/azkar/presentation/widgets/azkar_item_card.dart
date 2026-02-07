import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';

class AzkarItemCard extends StatefulWidget {
  final Azkar azkar;

  const AzkarItemCard({
    super.key,
    required this.azkar,
  });

  @override
  State<AzkarItemCard> createState() => _AzkarItemCardState();
}

class _AzkarItemCardState extends State<AzkarItemCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.azkar.repeat ?? 0;
    
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }



  void _decrementCount() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
    }
  }

  void _resetCount() {
    setState(() {
      _currentCount = widget.azkar.repeat ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Azkar Text
            Text(
              widget.azkar.text,
              style: const TextStyle(
                fontSize: 20,
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            
            const SizedBox(height: 16),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                  const SizedBox(width: 32),
                
                // Counter
                if (widget.azkar.repeat != null)
                  Row(
                    children: [
                      IconButton(
                        onPressed: _resetCount,
                        icon: const Icon(Icons.refresh),
                        color: Colors.grey[600],
                      ),
                      GestureDetector(
                        onTap: _decrementCount,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _currentCount > 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_currentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
