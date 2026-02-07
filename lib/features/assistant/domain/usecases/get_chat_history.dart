import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class GetChatHistory {
  final AssistantRepository repository;

  GetChatHistory(this.repository);

  Future<Either<Failure, List<ChatMessage>>> call(String chatId) async {
    return await repository.getChatHistory(chatId);
  }
}