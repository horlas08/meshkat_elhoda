import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/assistant_repository.dart';

class SendMessage {
  final AssistantRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call({
    required String chatId,
    required String message,
    required String model,
  }) async {
    return await repository.sendMessage(
      chatId: chatId,
      message: message,
      model: model,
    );
  }
}