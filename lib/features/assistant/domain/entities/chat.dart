import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const Chat({
    required this.id,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
  });

  @override
  List<Object?> get props => [id, createdAt, lastMessage, lastMessageTime];
}