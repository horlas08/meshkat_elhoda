import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat.dart';
import '../repositories/assistant_repository.dart';

class GetChatList {
  final AssistantRepository repository;

  GetChatList(this.repository);

  Future<Either<Failure, List<Chat>>> call() async {
    return await repository.getChatList();
  }
}