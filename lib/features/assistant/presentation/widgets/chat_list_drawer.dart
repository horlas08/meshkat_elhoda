import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quran_index/presentation/widgets/loading_widget.dart';
import '../../domain/entities/chat.dart';
import '../bloc/assistant_bloc.dart';
import '../bloc/assistant_event.dart';
import '../bloc/assistant_state.dart';

class ChatListDrawer extends StatefulWidget {
  const ChatListDrawer({Key? key}) : super(key: key);

  @override
  State<ChatListDrawer> createState() => _ChatListDrawerState();
}

class _ChatListDrawerState extends State<ChatListDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  void _loadChats() {
    if (mounted) {
      context.read<AssistantBloc>().add(LoadChatListEvent());
    }
  }

  void _createNewChat(BuildContext context) async {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [QuranLottieLoading()]),
        duration: Duration(seconds: 2),
      ),
    );

    context.read<AssistantBloc>().add(CreateNewChatEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.goldenColor),
            child: Text(
              AppLocalizations.of(context)!.chatList,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(AppLocalizations.of(context)!.newConversation),
            onTap: () => _createNewChat(context),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<AssistantBloc, AssistantState>(
              builder: (context, state) {
                // استخدام chats من أي حالة - هذا هو التغيير الرئيسي
                final chats = state.chats;

                if (state is AssistantLoading && chats.isEmpty) {
                  return const Center(child: QuranLottieLoading());
                }

                if (chats.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.noConversationsMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AssistantBloc>().add(LoadChatListEvent());
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return ChatTile(chat: chat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Chat chat;

  const ChatTile({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        chat.lastMessage ?? AppLocalizations.of(context)!.newConversation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(chat.lastMessageTime ?? chat.createdAt, context),
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        context.read<AssistantBloc>().add(SelectChatEvent(chat.id));
        Navigator.pop(context);
      },
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return AppLocalizations.of(
        context,
      )!.dayAgo(diff.inDays.toString());
    } else if (diff.inHours > 0) {
      return AppLocalizations.of(
        context,
      )!.hourAgo(diff.inHours.toString());
    } else if (diff.inMinutes > 0) {
      return AppLocalizations.of(
        context,
      )!.minuteAgo(diff.inMinutes.toString());
    } else {
      return AppLocalizations.of(context)!.now;
    }
  }
}
