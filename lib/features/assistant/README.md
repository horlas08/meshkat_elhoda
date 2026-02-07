# Smart Assistant Feature

## Overview
A Flutter feature implementing Clean Architecture with Firebase Firestore and OpenAI API integration.

## Architecture
```
lib/features/assistant/
├── data/
│   ├── models/
│   │   └── chat_message_model.dart
│   ├── datasources/
│   │   ├── assistant_remote_data_source.dart (OpenAI API)
│   │   └── assistant_local_data_source.dart (SharedPreferences)
│   └── repositories/
│       └── assistant_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── chat_message.dart
│   ├── repositories/
│   │   └── assistant_repository.dart
│   └── usecases/
│       ├── send_message.dart
│       ├── get_chat_history.dart
│       └── create_new_chat.dart
└── presentation/
    ├── bloc/
    │   ├── assistant_event.dart
    │   ├── assistant_state.dart
    │   └── assistant_bloc.dart
    ├── pages/
    │   └── assistant_screen.dart
    └── widgets/
        ├── message_bubble.dart
        ├── model_selector.dart
        └── input_bar.dart
```

## Usage

### 1. Set OpenAI API Key
```bash
flutter run --dart-define=OPENAI_API_KEY=your_api_key_here
```

### 2. Navigate to Assistant Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AssistantScreen(),
  ),
);
```

## Firebase Schema
```
/users/{uid}/chats/{chatId}/messages/{messageId}
{
  "id": "string",
  "role": "user|assistant", 
  "text": "string",
  "timestamp": "Timestamp",
  "model": "string"
}
```

## OpenAI Integration
- Endpoint: `https://api.openai.com/v1/chat/completions`
- Models: gpt-4, gpt-4o-mini, gpt-3.5-turbo
- Request format: `{"model": "gpt-4", "messages": [{"role": "user", "content": "Hello"}]}`

## Features
- ✅ Real-time chat with OpenAI
- ✅ Firebase Firestore storage
- ✅ Model selection (gpt-4, gpt-4o-mini, gpt-3.5-turbo)
- ✅ Offline support via Firestore cache
- ✅ Clean Architecture with BLoC
- ✅ Error handling with Either<Failure, Data>
- ✅ New chat creation
- ✅ Typing indicators
- ✅ Local preferences storage