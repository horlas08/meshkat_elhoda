import 'package:equatable/equatable.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object> get props => [];
}

class LoadChatHistory extends AssistantEvent {
  final String chatId;

  const LoadChatHistory(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SendMessageEvent extends AssistantEvent {
  final String chatId;
  final String message;
  final String model;

  const SendMessageEvent({
    required this.chatId,
    required this.message,
    required this.model,
  });

  @override
  List<Object> get props => [chatId, message, model];
}

class CreateNewChatEvent extends AssistantEvent {}

class LoadChatListEvent extends AssistantEvent {}

class SelectChatEvent extends AssistantEvent {
  final String chatId;

  const SelectChatEvent(this.chatId);

  @override
  List<Object> get props => [chatId];
}

class SelectModelEvent extends AssistantEvent {
  final String model;

  const SelectModelEvent(this.model);

  @override
  List<Object> get props => [model];
}