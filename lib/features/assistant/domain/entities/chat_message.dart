import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;
  final String model;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    required this.model,
  });

  @override
  List<Object> get props => [id, role, text, timestamp, model];
}