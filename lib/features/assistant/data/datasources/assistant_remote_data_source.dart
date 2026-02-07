import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/chat_message_model.dart';

abstract class AssistantRemoteDataSource {
  Future<String> sendMessageToOpenAI({
    required List<ChatMessageModel> messages,
    required String model,
  });
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';
  // ضع الـ API key مباشرة هنا
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY'); // Use --dart-define=OPENAI_API_KEY=...
  
  AssistantRemoteDataSourceImpl({required this.client});

  @override
  Future<String> sendMessageToOpenAI({
    required List<ChatMessageModel> messages,
    required String model,
  }) async {
    // إزالة التحقق من environment variable
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages
            .map((msg) => {'role': msg.role, 'content': msg.text})
            .toList(),
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw ServerException(
        message: 'OpenAI API error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
