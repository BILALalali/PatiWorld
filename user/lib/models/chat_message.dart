/// Model class representing a chat message
/// 
/// This class follows OOP principles by encapsulating message data
/// and providing clear getters for message properties.
class ChatMessage {
  /// The text content of the message
  final String text;
  
  /// Whether this message is from the user (true) or bot (false)
  final bool isUser;
  
  /// Timestamp when the message was created
  final DateTime timestamp;

  /// Creates a new ChatMessage instance
  /// 
  /// [text] - The message text content
  /// [isUser] - Whether the message is from the user (default: true)
  /// [timestamp] - When the message was created (default: now)
  ChatMessage({
    required this.text,
    this.isUser = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a user message
  factory ChatMessage.user(String text) {
    return ChatMessage(text: text, isUser: true);
  }

  /// Creates a bot message
  factory ChatMessage.bot(String text) {
    return ChatMessage(text: text, isUser: false);
  }

  /// Converts the message to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a ChatMessage from a JSON map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool? ?? true,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'ChatMessage(text: $text, isUser: $isUser, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(text, isUser, timestamp);
}

