import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failure.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_chat_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatConversationPage extends StatefulWidget {
  static const routeName = '/chat-conversation';
  
  const ChatConversationPage({super.key});

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final GetChatMessages _getChatMessages = sl<GetChatMessages>();
  final SendMessage _sendMessage = sl<SendMessage>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  Chat? _chat;
  List<Message> _messages = [];
  StreamSubscription<dartz.Either<Failure, Message>>? _messageSubscription;
  bool _isLoading = true;
  String? _error;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Chat) {
      _chat = args;
      _loadMessages();
      _subscribeToMessages();
    } else {
      setState(() {
        _error = 'Invalid chat data';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_chat == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messageStream = await _getChatMessages(_chat!.id);
      _messageSubscription = messageStream.listen(
        (messageEither) {
          messageEither.fold(
            (failure) {
              setState(() {
                _error = failure.message;
                _isLoading = false;
              });
            },
            (message) {
              setState(() {
                _messages.add(message);
                _isLoading = false;
              });
              _scrollToBottom();
            },
          );
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _subscribeToMessages() {
    // Real-time messages are handled by the stream from _getChatMessages
  }

  Future<void> _sendMessageAction() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _chat == null || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final result = await _sendMessage.call(_chat!.id, message, 'text');
    
    setState(() {
      _isSending = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        _messageController.clear();
        _scrollToBottom();
      },
    );
  }

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

  String _getChatTitle() {
    if (_chat == null) return 'Chat';
    
    // Show the other user's name
    final currentUserId = 'current_user_id'; // TODO: Get from auth
    if (_chat!.user1.id == currentUserId) {
      return _chat!.user2.name.isNotEmpty ? _chat!.user2.name : 'Unknown User';
    } else {
      return _chat!.user1.name.isNotEmpty ? _chat!.user1.name : 'Unknown User';
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getChatTitle().isNotEmpty ? _getChatTitle()[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3F51F3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getChatTitle(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Online',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // TODO: Implement video call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: _buildMessagesArea(),
          ),
          
          // Message input
          MessageInput(
            controller: _messageController,
            onSend: _sendMessageAction,
            isSending: _isSending,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51F3)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMyMessage = message.sender.id == 'current_user_id'; // TODO: Get from auth
        
        return MessageBubble(
          message: message,
          isMyMessage: isMyMessage,
        );
      },
    );
  }
}
