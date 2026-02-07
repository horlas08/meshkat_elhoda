import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/assistant_bloc.dart';
import '../bloc/assistant_event.dart';
import '../bloc/assistant_state.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({Key? key}) : super(key: key);

  static const List<String> availableModels = [
    'gpt-4',
    'gpt-4o-mini',
    'gpt-3.5-turbo',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantBloc, AssistantState>(
      builder: (context, state) {
        final selectedModel = state is AssistantLoaded
            ? state.selectedModel
            : state is AssistantSending
                ? state.selectedModel
                : 'gpt-4o-mini';

        return PopupMenuButton<String>(
          icon: const Icon(Icons.settings),
          onSelected: (model) {
            context.read<AssistantBloc>().add(SelectModelEvent(model));
          },
          itemBuilder: (context) => availableModels
              .map(
                (model) => PopupMenuItem<String>(
                  value: model,
                  child: Row(
                    children: [
                      Icon(
                        selectedModel == model
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(model),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}