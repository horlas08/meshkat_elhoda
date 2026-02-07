import 'package:equatable/equatable.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_message.dart';

abstract class AssistantState extends Equatable {
  final List<Chat> chats;
  final int dailyQuestionCount;

  const AssistantState({this.chats = const [], this.dailyQuestionCount = 0});

  @override
  List<Object> get props => [chats, dailyQuestionCount];
}

class AssistantInitial extends AssistantState {
  const AssistantInitial() : super();
}

class AssistantLoading extends AssistantState {
  const AssistantLoading({super.chats, super.dailyQuestionCount});
}

class AssistantError extends AssistantState {
  final String message;

  const AssistantError(this.message, {super.chats, super.dailyQuestionCount});

  @override
  List<Object> get props => [message, ...super.props];
}

class ChatListLoaded extends AssistantState {
  const ChatListLoaded(List<Chat> chats) : super(chats: chats);
}

class AssistantLoaded extends AssistantState {
  final List<ChatMessage> messages;
  final String currentChatId;
  final String selectedModel;

  const AssistantLoaded({
    required this.messages,
    required this.currentChatId,
    required this.selectedModel,
    super.chats = const [],
    super.dailyQuestionCount = 0,
  });

  @override
  List<Object> get props => [
    messages,
    currentChatId,
    selectedModel,
    ...super.props,
  ];
}

class AssistantSending extends AssistantState {
  final List<ChatMessage> messages;
  final String selectedModel;
  final String currentChatId;

  const AssistantSending({
    required this.messages,
    required this.selectedModel,
    required this.currentChatId,
    super.chats = const [],
    super.dailyQuestionCount = 0,
  });

  @override
  List<Object> get props => [
    messages,
    selectedModel,
    currentChatId,
    ...super.props,
  ];
}
