import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/dialogflow/v2.dart' as dialogflow;
import 'package:googleapis_auth/auth_io.dart';
import '../models/chat_message.dart';

/// Service class for interacting with DialogFlow chatbot
/// 
/// This class follows OOP principles by:
/// - Encapsulating DialogFlow API interactions
/// - Providing a clean interface for chat operations
/// - Handling authentication and session management
/// - Separating concerns from UI components
class DialogFlowService {
  // Singleton pattern for service instance
  static DialogFlowService? _instance;
  
  // Private constructor
  DialogFlowService._();
  
  /// Gets the singleton instance of DialogFlowService
  factory DialogFlowService() {
    _instance ??= DialogFlowService._();
    return _instance!;
  }

  // Service account credentials
  Map<String, dynamic>? _credentials;
  
  // Authenticated HTTP client
  AutoRefreshingAuthClient? _authClient;
  
  // DialogFlow API client
  dialogflow.DialogflowApi? _dialogflowApi;
  
  // Project ID from credentials
  String? _projectId;
  
  // Session ID for conversation context
  String? _sessionId;
  
  // Language code (default: Arabic)
  String _languageCode = 'ar';

  /// Initializes the DialogFlow service with credentials
  /// 
  /// Loads credentials from assets and authenticates with Google
  /// Returns true if initialization is successful
  Future<bool> initialize() async {
    try {
      // Load credentials from assets
      final String credentialsString = await rootBundle.loadString(
        'assets/dialog_flow_auth.json',
      );
      _credentials = json.decode(credentialsString) as Map<String, dynamic>;
      _projectId = _credentials!['project_id'] as String?;

      if (_projectId == null) {
        throw Exception('Project ID not found in credentials');
      }

      // Create service account credentials
      final accountCredentials = ServiceAccountCredentials.fromJson(
        _credentials!,
      );

      // Create authenticated client
      final scopes = [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/dialogflow',
      ];

      _authClient = await clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      // Initialize DialogFlow API
      _dialogflowApi = dialogflow.DialogflowApi(_authClient!);

      // Generate a unique session ID
      _sessionId = _generateSessionId();

      return true;
    } catch (e) {
      print('Error initializing DialogFlow service: $e');
      return false;
    }
  }

  /// Generates a unique session ID for the conversation
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Sends a message to DialogFlow and returns the bot's response
  /// 
  /// [message] - The user's message text
  /// Returns a ChatMessage with the bot's response, or null on error
  Future<ChatMessage?> sendMessage(String message) async {
    if (_dialogflowApi == null || _projectId == null || _sessionId == null) {
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }
    }

    try {
      // Create the session path
      final sessionPath = 'projects/$_projectId/agent/sessions/$_sessionId';

      // Create the text input
      final textInput = dialogflow.GoogleCloudDialogflowV2TextInput()
        ..text = message
        ..languageCode = _languageCode;

      // Create the query input
      final queryInput = dialogflow.GoogleCloudDialogflowV2QueryInput()
        ..text = textInput;

      // Create the detect intent request
      final request = dialogflow.GoogleCloudDialogflowV2DetectIntentRequest()
        ..queryInput = queryInput;

      // Send the request
      final response = await _dialogflowApi!.projects.agent.sessions.detectIntent(
        request,
        sessionPath,
      );

      // Extract the response text
      if (response.queryResult != null &&
          response.queryResult!.fulfillmentMessages != null &&
          response.queryResult!.fulfillmentMessages!.isNotEmpty) {
        final fulfillmentMessage = response.queryResult!.fulfillmentMessages!.first;
        
        String responseText = '';
        if (fulfillmentMessage.text != null &&
            fulfillmentMessage.text!.text != null &&
            fulfillmentMessage.text!.text!.isNotEmpty) {
          responseText = fulfillmentMessage.text!.text!.first;
        } else if (response.queryResult!.fulfillmentText != null) {
          responseText = response.queryResult!.fulfillmentText!;
        } else {
          responseText = 'Mesajınızı anlayamadım.';
        }

        return ChatMessage.bot(responseText);
      } else if (response.queryResult?.fulfillmentText != null) {
        return ChatMessage.bot(response.queryResult!.fulfillmentText!);
      } else {
        return ChatMessage.bot('Mesajınızı anlayamadım.');
      }
    } catch (e) {
      print('Error sending message to DialogFlow: $e');
      return ChatMessage.bot(
        'Sohbet botu ile iletişimde bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  /// Sets the language code for the conversation
  /// 
  /// [languageCode] - ISO 639-1 language code (e.g., 'ar', 'en', 'tr')
  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
  }

  /// Gets the current language code
  String get languageCode => _languageCode;

  /// Resets the session to start a new conversation
  void resetSession() {
    _sessionId = _generateSessionId();
  }

  /// Disposes of resources
  void dispose() {
    _authClient?.close();
    _authClient = null;
    _dialogflowApi = null;
    _credentials = null;
    _projectId = null;
    _sessionId = null;
  }
}

