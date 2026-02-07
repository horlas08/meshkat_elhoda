import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/assistant_repository.dart';

class CreateNewChat {
  final AssistantRepository repository;

  CreateNewChat(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.createNewChat();
  }
}