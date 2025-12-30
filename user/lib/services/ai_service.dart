import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

/// Service class for interacting with AI chatbot via OpenRouter API
///
/// This class follows OOP principles by:
/// - Encapsulating AI API interactions
/// - Providing a clean interface for chat operations
/// - Handling authentication and request management
/// - Separating concerns from UI components
class AIService {
  // Singleton pattern for service instance
  static AIService? _instance;

  // Private constructor
  AIService._();

  /// Gets the singleton instance of AIService
  factory AIService() {
    _instance ??= AIService._();
    return _instance!;
  }

  // API Configuration
  static const String _apiKey =
      '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';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'openai/gpt-4o-mini';

  // System prompt for the AI assistant
  static const String _systemPrompt =
      'Sen PatiWorld için çalışan yardımcı bir AI asistanısın. '
      'Kullanıcılara evcil hayvanlar, özellikle kedi ve köpekler hakkında '
      'faydalı bilgiler sağlıyorsun. Dostça, bilgili ve yardımcı bir ton kullan. '
      'Sorulara Türkçe olarak yanıt ver.';

  /// Conversation history for context
  List<Map<String, String>> _conversationHistory = [];

  /// Initializes the AI service
  /// Returns true if initialization is successful
  Future<bool> initialize() async {
    try {
      // Reset conversation history
      _conversationHistory = [
        {'role': 'system', 'content': _systemPrompt},
      ];
      return true;
    } catch (e) {
      print('Error initializing AI service: $e');
      return false;
    }
  }

  /// Sends a message to the AI and returns the bot's response
  ///
  /// [message] - The user's message text
  /// Returns a ChatMessage with the bot's response, or null on error
  Future<ChatMessage?> sendMessage(String message) async {
    try {
      // Add user message to conversation history
      _conversationHistory.add({'role': 'user', 'content': message});

      // Prepare the request body
      final requestBody = {'model': _model, 'messages': _conversationHistory};

      // Make the API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://patiworld.app', // Optional: for tracking
          'X-Title': 'PatiWorld', // Optional: for tracking
        },
        body: jsonEncode(requestBody),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract the AI's response
        if (responseData['choices'] != null &&
            responseData['choices'] is List &&
            (responseData['choices'] as List).isNotEmpty) {
          final choice =
              (responseData['choices'] as List).first as Map<String, dynamic>;
          final messageContent = choice['message'] as Map<String, dynamic>;
          final aiResponse = messageContent['content'] as String? ?? '';

          if (aiResponse.isNotEmpty) {
            // Add AI response to conversation history
            _conversationHistory.add({
              'role': 'assistant',
              'content': aiResponse,
            });

            return ChatMessage.bot(aiResponse);
          }
        }

        return ChatMessage.bot(
          'Üzgünüm, bir yanıt oluşturamadım. Lütfen tekrar deneyin.',
        );
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return ChatMessage.bot(
          'Sohbet botu ile iletişimde bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }
    } catch (e) {
      print('Error sending message to AI: $e');
      return ChatMessage.bot(
        'Sohbet botu ile iletişimde bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  /// Resets the conversation to start a new chat
  void resetConversation() {
    _conversationHistory = [
      {'role': 'system', 'content': _systemPrompt},
    ];
  }

  /// Disposes of resources
  void dispose() {
    _conversationHistory.clear();
  }
}
