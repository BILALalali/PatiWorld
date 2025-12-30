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
      // Validate API key format
      if (_apiKey.isEmpty || !_apiKey.startsWith('sk-or-v1-')) {
        print('Invalid API key format');
        return ChatMessage.bot(
          'Yapılandırma hatası. Lütfen daha sonra tekrar deneyin.',
        );
      }

      // Add user message to conversation history
      _conversationHistory.add({'role': 'user', 'content': message});

      // Prepare the request body
      final requestBody = {'model': _model, 'messages': _conversationHistory};

      // Debug: Print API key length (first and last 4 chars for security)
      print(
        'API Key check: ${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 4)} (length: ${_apiKey.length})',
      );

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
        try {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;

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

          // If we reach here, the response format was unexpected
          print('AI API Response format error: ${response.body}');
          return ChatMessage.bot(
            'Üzgünüm, bir yanıt oluşturamadım. Lütfen tekrar deneyin.',
          );
        } catch (parseError) {
          print('Error parsing AI response: $parseError');
          print('Response body: ${response.body}');
          return ChatMessage.bot(
            'Yanıt işlenirken bir hata oluştu. Lütfen tekrar deneyin.',
          );
        }
      } else {
        print('AI API Error: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Remove the user message from history since the request failed
        if (_conversationHistory.isNotEmpty &&
            _conversationHistory.last['role'] == 'user') {
          _conversationHistory.removeLast();
        }

        String errorMessage = 'Sohbet botu ile iletişimde bir hata oluştu.';
        if (response.statusCode == 401) {
          errorMessage =
              'Kimlik doğrulama hatası. Lütfen daha sonra tekrar deneyin.';
        } else if (response.statusCode == 429) {
          errorMessage =
              'Çok fazla istek. Lütfen birkaç saniye sonra tekrar deneyin.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
        }

        return ChatMessage.bot(errorMessage);
      }
    } catch (e, stackTrace) {
      print('Error sending message to AI: $e');
      print('Stack trace: $stackTrace');

      // Remove the user message from history since the request failed
      if (_conversationHistory.isNotEmpty &&
          _conversationHistory.last['role'] == 'user') {
        _conversationHistory.removeLast();
      }

      return ChatMessage.bot(
        'Bağlantı hatası oluştu. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
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
