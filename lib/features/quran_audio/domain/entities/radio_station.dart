import 'package:equatable/equatable.dart';

class RadioStation extends Equatable {
  final String id;
  final String name;
  final String url;
  final String language;
  final String? description;
  final bool isActive;

  const RadioStation({
    required this.id,
    required this.name,
    required this.url,
    required this.language,
    this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, url, language, description, isActive];

  RadioStation copyWith({
    String? id,
    String? name,
    String? url,
    String? language,
    String? description,
    bool? isActive,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      language: language ?? this.language,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
