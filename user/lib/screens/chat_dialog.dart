import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/dialogflow_service.dart';
import '../constants/app_constants.dart';

/// A dialog/bottom sheet widget for chatting with the DialogFlow chatbot
///
/// This widget follows OOP principles by:
/// - Encapsulating chat UI logic
/// - Managing its own state
/// - Providing a clean interface for chat interactions
/// - Supporting both dialog and bottom sheet modes
class ChatDialog extends StatefulWidget {
  /// Whether to show as a bottom sheet instead of a dialog
  final bool isBottomSheet;

  const ChatDialog({super.key, this.isBottomSheet = false});

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DialogFlowService _dialogFlowService = DialogFlowService();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  /// Initializes the DialogFlow service
  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    final initialized = await _dialogFlowService.initialize();

    if (initialized && mounted) {
      setState(() {
        _isInitialized = true;
        _isLoading = false;
        // Add welcome message
        _messages.add(
          ChatMessage.bot(
            'Merhaba! Ben PatiWorld akıllı asistanıyım. Size nasıl yardımcı olabilirim?',
          ),
        );
      });
      _scrollToBottom();
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage.bot(
            'Üzgünüz, sohbet botuna bağlanırken bir hata oluştu. Lütfen tekrar deneyin.',
          ),
        );
      });
    }
  }

  /// Sends a message to the chatbot
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading || !_isInitialized) return;

    // Add user message
    final userMessage = ChatMessage.user(text);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Get bot response
    final botMessage = await _dialogFlowService.sendMessage(text);

    if (mounted) {
      setState(() {
        if (botMessage != null) {
          _messages.add(botMessage);
        } else {
          _messages.add(
            ChatMessage.bot(
              'Mesaj gönderilirken bir hata oluştu. Lütfen tekrar deneyin.',
            ),
          );
        }
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  /// Scrolls to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: widget.isBottomSheet
          ? MediaQuery.of(context).size.height * 0.85
          : MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppConstants.largeRadius),
          topRight: const Radius.circular(AppConstants.largeRadius),
          bottomLeft: widget.isBottomSheet
              ? const Radius.circular(AppConstants.largeRadius)
              : Radius.zero,
          bottomRight: widget.isBottomSheet
              ? const Radius.circular(AppConstants.largeRadius)
              : Radius.zero,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          // Messages List
          Expanded(child: _buildMessagesList()),
          // Input Area
          _buildInputArea(context),
        ],
      ),
    );

    if (widget.isBottomSheet) {
      return content;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      ),
      child: content,
    );
  }

  /// Builds the header of the chat dialog
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.largeRadius),
          topRight: Radius.circular(AppConstants.largeRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          const Expanded(
            child: Text(
              'PatiWorld Asistanı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Builds the messages list
  Widget _buildMessagesList() {
    if (_messages.isEmpty && !_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          // Loading indicator
          return _buildLoadingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  /// Builds a message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppConstants.smallPadding),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: AppConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppConstants.mediumRadius),
                  topRight: const Radius.circular(AppConstants.mediumRadius),
                  bottomLeft: Radius.circular(
                    isUser ? AppConstants.mediumRadius : 0,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? 0 : AppConstants.mediumRadius,
                  ),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppConstants.smallPadding),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the loading indicator for bot responses
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the input area
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.mediumPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isLoading && _isInitialized,
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Container(
              decoration: BoxDecoration(
                color: (_isLoading || !_isInitialized)
                    ? Colors.grey[300]
                    : Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: (_isLoading || !_isInitialized)
                    ? null
                    : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
