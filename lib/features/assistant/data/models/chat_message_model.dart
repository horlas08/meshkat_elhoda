import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required String id,
    required String role,
    required String text,
    required DateTime timestamp,
    required String model,
  }) : super(
          id: id,
          role: role,
          text: text,
          timestamp: timestamp,
          model: model,
        );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      role: json['role'],
      text: json['text'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      model: json['model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'model': model,
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      role: entity.role,
      text: entity.text,
      timestamp: entity.timestamp,
      model: entity.model,
    );
  }
}