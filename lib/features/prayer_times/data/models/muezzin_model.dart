import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';

class MuezzinModel extends Muezzin {
  const MuezzinModel({
    required String id,
    required String name,
    required String fajrAudioPath,
    required String regularAudioPath,
  }) : super(
         id: id,
         name: name,
         fajrAudioPath: fajrAudioPath,
         regularAudioPath: regularAudioPath,
       );

  factory MuezzinModel.fromJson(Map<String, dynamic> json) {
    final audio = json['audio'] as Map<String, dynamic>;
    return MuezzinModel(
      id: json['id'] as String,
      name: json['name'] as String,
      fajrAudioPath: audio['fajr'] as String,
      regularAudioPath: audio['regular'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'audio': {'fajr': fajrAudioPath, 'regular': regularAudioPath},
    };
  }
}
