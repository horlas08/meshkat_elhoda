import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required String id,
    required DateTime createdAt,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) : super(
         id: id,
         createdAt: createdAt,
         lastMessage: lastMessage,
         lastMessageTime: lastMessageTime,
       );

  factory ChatModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatModel(
      id: id,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
    );
  }
}
