import 'package:equatable/equatable.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/azkar_category.dart';
import 'package:meshkat_elhoda/features/azkar/domain/entities/allah_name.dart';

abstract class AzkarState extends Equatable {
  const AzkarState();

  @override
  List<Object?> get props => [];
}

class AzkarInitial extends AzkarState {
  const AzkarInitial();
}

class AzkarLoading extends AzkarState {
  const AzkarLoading();
}

class AzkarCategoriesLoaded extends AzkarState {
  final List<AzkarCategory> categories;

  const AzkarCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class AzkarChaptersLoaded extends AzkarState {
  final List<Azkar> chapters;

  const AzkarChaptersLoaded(this.chapters);

  @override
  List<Object?> get props => [chapters];
}

class AzkarItemsLoaded extends AzkarState {
  final List<Azkar> items;

  const AzkarItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class AllahNamesLoaded extends AzkarState {
  final List<AllahName> names;

  const AllahNamesLoaded(this.names);

  @override
  List<Object?> get props => [names];
}

class AzkarAudioLoaded extends AzkarState {
  final String audioUrl;

  const AzkarAudioLoaded(this.audioUrl);

  @override
  List<Object?> get props => [audioUrl];
}

class AzkarError extends AzkarState {
  final String message;

  const AzkarError(this.message);

  @override
  List<Object?> get props => [message];
}

class AzkarOffline extends AzkarState {
  final String message;

  const AzkarOffline(this.message);

  @override
  List<Object?> get props => [message];
}
