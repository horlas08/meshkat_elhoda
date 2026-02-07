import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/utils/app_exception.dart';
import 'package:meshkat_elhoda/features/quran_audio/data/models/downloaded_audio_model.dart';

abstract class AudioDownloadService {
  Future<void> downloadSurah({
    required String url,
    required String reciterName,
    required int surahNumber,
    required String surahName,
  });

  Future<List<DownloadedAudioModel>> getOfflineAudios();

  Future<void> deleteOfflineAudio(String id);
}

class AudioDownloadServiceImpl implements AudioDownloadService {
  final SharedPreferences sharedPreferences;
  final http.Client client;

  static const String _offlineAudiosKey = 'offline_audios';

  AudioDownloadServiceImpl({
    required this.sharedPreferences,
    required this.client,
  });

  @override
  Future<void> downloadSurah({
    required String url,
    required String reciterName,
    required int surahNumber,
    required String surahName,
  }) async {
    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw AppException(message: 'Failed to download audio');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${reciterName}_$surahNumber.mp3'.replaceAll(
        ' ',
        '_',
      ); // Sanitize filename
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      final id = '${reciterName}_$surahNumber';
      final downloadedAudio = DownloadedAudioModel(
        id: id,
        reciterName: reciterName,
        surahNumber: surahNumber,
        surahName: surahName,
        localPath: file.path,
        fileSize: response.bodyBytes.length,
        downloadedAt: DateTime.now().toIso8601String(),
      );

      await _saveMetadata(downloadedAudio);
    } catch (e) {
      throw AppException(message: 'Error downloading audio: $e');
    }
  }

  Future<void> _saveMetadata(DownloadedAudioModel audio) async {
    final List<String> jsonList =
        sharedPreferences.getStringList(_offlineAudiosKey) ?? [];

    // Remove existing entry if any (to update it)
    jsonList.removeWhere((item) {
      final map = json.decode(item);
      return map['id'] == audio.id;
    });

    jsonList.add(json.encode(audio.toJson()));
    await sharedPreferences.setStringList(_offlineAudiosKey, jsonList);
  }

  @override
  Future<List<DownloadedAudioModel>> getOfflineAudios() async {
    final List<String> jsonList =
        sharedPreferences.getStringList(_offlineAudiosKey) ?? [];

    return jsonList
        .map((item) => DownloadedAudioModel.fromJson(json.decode(item)))
        .toList();
  }

  @override
  Future<void> deleteOfflineAudio(String id) async {
    final List<String> jsonList =
        sharedPreferences.getStringList(_offlineAudiosKey) ?? [];

    String? pathToDelete;

    // Find and remove from list
    jsonList.removeWhere((item) {
      final map = json.decode(item);
      if (map['id'] == id) {
        pathToDelete = map['localPath'];
        return true;
      }
      return false;
    });

    await sharedPreferences.setStringList(_offlineAudiosKey, jsonList);

    // Delete file
    if (pathToDelete != null) {
      final file = File(pathToDelete!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
