import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool enabled;

  const InputBar({
    Key? key,
    required this.onSendMessage,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && widget.enabled) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: widget.enabled
                    ? AppLocalizations.of(context)!.typeMessageHint
                    : AppLocalizations.of(context)!.pleaseWaitHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: widget.enabled ? _sendMessage : null,
            mini: true,
            child: Icon(
              Icons.send,
              color: widget.enabled ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}