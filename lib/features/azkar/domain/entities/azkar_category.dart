import 'package:equatable/equatable.dart';

class AzkarCategory extends Equatable {
  final int id;
  final String title;
  final String? description;

  const AzkarCategory({
    required this.id,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}
