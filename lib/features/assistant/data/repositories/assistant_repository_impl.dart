import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_local_data_source.dart';
import '../datasources/assistant_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../../domain/entities/chat.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource remoteDataSource;
  final AssistantLocalDataSource localDataSource;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AssistantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firestore,
    required this.auth,
  });

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatHistory(
    String chatId,
  ) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null)
        throw const ServerException(message: 'User not authenticated');

      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final messages = snapshot.docs
          .map(
            (doc) => ChatMessageModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();

      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get chat history'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String chatId,
    required String message,
    required String model,
  }) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null)
        throw const ServerException(message: 'User not authenticated');

      // Add user message to Firebase
      final userMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        text: message,
        timestamp: DateTime.now(),
        model: model,
      );

      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(userMessage.toJson());

      // تحديث lastMessage مع أول 5 كلمات من رسالة المستخدم
      final firstFewWords = _getFirstFewWords(message);
      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .update({
            'lastMessage': firstFewWords,
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

      // Get chat history for context
      final historyResult = await getChatHistory(chatId);
      final history = historyResult.fold((l) => <ChatMessage>[], (r) => r);
      final contextMessages = history
          .map((msg) => ChatMessageModel.fromEntity(msg))
          .toList();

      // Call OpenAI API
      final aiResponse = await remoteDataSource.sendMessageToOpenAI(
        messages: contextMessages,
        model: model,
      );

      // Add assistant response to Firebase
      final assistantMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        text: aiResponse,
        timestamp: DateTime.now(),
        model: model,
      );

      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(assistantMessage.toJson());

      await localDataSource.saveLastChatId(chatId);
      return Right(assistantMessage);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send message'));
    }
  }

  @override
  Future<Either<Failure, String>> createNewChat() async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null)
        throw const ServerException(message: 'User not authenticated');

      final chatId = DateTime.now().millisecondsSinceEpoch.toString();
      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .set({
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': 'محادثة جديدة', // تعيين قيمة افتراضية
            'lastMessageTime': FieldValue.serverTimestamp(),
          });

      await localDataSource.saveLastChatId(chatId);
      return Right(chatId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create new chat'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null)
        throw const ServerException(message: 'User not authenticated');

      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(chatId)
          .delete();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete chat'));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getChatList() async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null)
        throw const ServerException(message: 'User not authenticated');

      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .orderBy('lastMessageTime', descending: true) // ترتيب حسب آخر رسالة
          .get();

      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc.id, doc.data()))
          .toList();

      return Right(chats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get chat list'));
    }
  }

  // دالة لاستخراج أول كلمات من النص
  String _getFirstFewWords(String text, {int wordCount = 5}) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= wordCount) {
      return text;
    }
    return words.take(wordCount).join(' ') + '...';
  }
}
