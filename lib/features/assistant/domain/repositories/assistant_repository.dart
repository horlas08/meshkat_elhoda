import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat.dart';

abstract class AssistantRepository {
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(String chatId);
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String chatId,
    required String message,
    required String model,
  });
  Future<Either<Failure, String>> createNewChat();
  Future<Either<Failure, void>> deleteChat(String chatId);
  Future<Either<Failure, List<Chat>>> getChatList();
}