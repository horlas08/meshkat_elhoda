import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/assistant_local_data_source.dart';
import '../../domain/usecases/create_new_chat.dart';
import '../../domain/usecases/get_chat_history.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_chat_list.dart';
import 'assistant_event.dart';
import 'assistant_state.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final GetChatHistory getChatHistory;
  final SendMessage sendMessage;
  final CreateNewChat createNewChat;
  final GetChatList getChatList;
  final AssistantLocalDataSource localDataSource;

  AssistantBloc({
    required this.getChatHistory,
    required this.sendMessage,
    required this.createNewChat,
    required this.getChatList,
    required this.localDataSource,
  }) : super(AssistantInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateNewChatEvent>(_onCreateNewChat);
    on<SelectModelEvent>(_onSelectModel);
    on<LoadChatListEvent>(_onLoadChatList);
    on<SelectChatEvent>(_onSelectChat);
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<AssistantState> emit,
  ) async {
    // الحفاظ على قائمة المحادثات الحالية
    final currentChats = state.chats;
    final dailyCount = await localDataSource.getDailyQuestionCount();
    emit(AssistantLoading(chats: currentChats, dailyQuestionCount: dailyCount));

    final result = await getChatHistory(event.chatId);
    final selectedModel = await localDataSource.getSelectedModel();

    result.fold(
      (failure) => emit(
        AssistantError(
          failure.message,
          chats: currentChats,
          dailyQuestionCount: dailyCount,
        ),
      ),
      (messages) => emit(
        AssistantLoaded(
          messages: messages,
          currentChatId: event.chatId,
          selectedModel: selectedModel,
          chats: currentChats,
          dailyQuestionCount: dailyCount,
        ),
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<AssistantState> emit,
  ) async {
    if (state is! AssistantLoaded) return;

    final currentState = state as AssistantLoaded;

    // Increment question count
    await localDataSource.incrementDailyQuestionCount();
    final newDailyCount = await localDataSource.getDailyQuestionCount();

    // Emit loading state
    emit(
      AssistantSending(
        messages: currentState.messages,
        selectedModel: currentState.selectedModel,
        currentChatId: currentState.currentChatId,
        chats: currentState.chats,
        dailyQuestionCount: newDailyCount,
      ),
    );

    try {
      // Send message
      final messageResult = await sendMessage(
        chatId: event.chatId,
        message: event.message,
        model: event.model,
      );

      // Handle message sending result
      await messageResult.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(
              AssistantError(
                failure.message,
                chats: currentState.chats,
                dailyQuestionCount: newDailyCount,
              ),
            );
          }
        },
        (_) async {
          // After sending message, update chat list to get the new lastMessage
          final chatListResult = await getChatList();

          if (!emit.isDone) {
            await chatListResult.fold(
              (failure) async {
                emit(
                  AssistantError(
                    failure.message,
                    chats: currentState.chats,
                    dailyQuestionCount: newDailyCount,
                  ),
                );
              },
              (updatedChats) async {
                // Get updated chat history
                final historyResult = await getChatHistory(event.chatId);

                if (!emit.isDone) {
                  historyResult.fold(
                    (failure) {
                      emit(
                        AssistantError(
                          failure.message,
                          chats: updatedChats,
                          dailyQuestionCount: newDailyCount,
                        ),
                      );
                    },
                    (messages) {
                      emit(
                        AssistantLoaded(
                          messages: messages,
                          currentChatId: event.chatId,
                          selectedModel: event.model,
                          chats: updatedChats,
                          dailyQuestionCount: newDailyCount,
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(
          AssistantError(
            'حدث خطأ غير متوقع: $e',
            chats: currentState.chats,
            dailyQuestionCount: newDailyCount,
          ),
        );
      }
    }
  }

  Future<void> _onCreateNewChat(
    CreateNewChatEvent event,
    Emitter<AssistantState> emit,
  ) async {
    try {
      final currentChats = state.chats;
      final dailyCount = await localDataSource.getDailyQuestionCount();

      // Emit loading state
      if (!emit.isDone) {
        emit(
          AssistantLoading(chats: currentChats, dailyQuestionCount: dailyCount),
        );
      }

      // Create new chat
      final result = await createNewChat();
      if (emit.isDone) return;

      final selectedModel = await localDataSource.getSelectedModel();
      if (emit.isDone) return;

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(
              AssistantError(
                failure.message,
                chats: currentChats,
                dailyQuestionCount: dailyCount,
              ),
            );
          }
        },
        (chatId) async {
          // Load updated chat list after creating a new chat
          final chatListResult = await getChatList();
          if (emit.isDone) return;

          await chatListResult.fold(
            (failure) async {
              if (!emit.isDone) {
                emit(
                  AssistantError(
                    failure.message,
                    chats: currentChats,
                    dailyQuestionCount: dailyCount,
                  ),
                );
              }
            },
            (updatedChats) async {
              if (!emit.isDone) {
                emit(
                  AssistantLoaded(
                    messages: const [],
                    currentChatId: chatId,
                    selectedModel: selectedModel,
                    chats: updatedChats,
                    dailyQuestionCount: dailyCount,
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        final dailyCount = await localDataSource.getDailyQuestionCount();
        emit(
          AssistantError(
            'حدث خطأ غير متوقع: $e',
            chats: state.chats,
            dailyQuestionCount: dailyCount,
          ),
        );
      }
    }
  }

  Future<void> _onSelectModel(
    SelectModelEvent event,
    Emitter<AssistantState> emit,
  ) async {
    await localDataSource.saveSelectedModel(event.model);

    if (state is AssistantLoaded) {
      final currentState = state as AssistantLoaded;
      emit(
        AssistantLoaded(
          messages: currentState.messages,
          currentChatId: currentState.currentChatId,
          selectedModel: event.model,
          chats: currentState.chats,
          dailyQuestionCount: currentState.dailyQuestionCount,
        ),
      );
    }
  }

  Future<void> _onLoadChatList(
    LoadChatListEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final currentChats = state.chats;
    final dailyCount = await localDataSource.getDailyQuestionCount();
    emit(AssistantLoading(chats: currentChats, dailyQuestionCount: dailyCount));

    final result = await getChatList();

    result.fold(
      (failure) => emit(
        AssistantError(
          failure.message,
          chats: currentChats,
          dailyQuestionCount: dailyCount,
        ),
      ),
      (chats) => emit(ChatListLoaded(chats)),
    );
  }

  Future<void> _onSelectChat(
    SelectChatEvent event,
    Emitter<AssistantState> emit,
  ) async {
    add(LoadChatHistory(event.chatId));
  }
}
