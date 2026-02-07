import 'package:equatable/equatable.dart';
import '../../domain/entities/quran_edition_entity.dart';

abstract class QuranSettingsState extends Equatable {
  const QuranSettingsState();

  @override
  List<Object?> get props => [];
}

class QuranSettingsInitial extends QuranSettingsState {}

class QuranSettingsLoading extends QuranSettingsState {}

class QuranSettingsLoaded extends QuranSettingsState {
  final List<QuranEditionEntity> availableTafsirs;
  final List<QuranEditionEntity> availableReciters;
  final String selectedTafsirId;
  final String selectedReciterId;

  const QuranSettingsLoaded({
    required this.availableTafsirs,
    required this.availableReciters,
    required this.selectedTafsirId,
    required this.selectedReciterId,
  });

  @override
  List<Object?> get props => [
    availableTafsirs,
    availableReciters,
    selectedTafsirId,
    selectedReciterId,
  ];

  QuranSettingsLoaded copyWith({
    List<QuranEditionEntity>? availableTafsirs,
    List<QuranEditionEntity>? availableReciters,
    String? selectedTafsirId,
    String? selectedReciterId,
  }) {
    return QuranSettingsLoaded(
      availableTafsirs: availableTafsirs ?? this.availableTafsirs,
      availableReciters: availableReciters ?? this.availableReciters,
      selectedTafsirId: selectedTafsirId ?? this.selectedTafsirId,
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
    );
  }
}

class QuranSettingsError extends QuranSettingsState {
  final String message;

  const QuranSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
