import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dartz/dartz.dart' as dartz;

import '../../../../core/error/failure.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_user_chats.dart';
import '../../../auth/domain/entities/user.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/user_status_list.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  static const routeName = '/chat-list';
  
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final GetUserChats _getUserChats = sl<GetUserChats>();
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getUserChats();
    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (chats) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      },
    );
    
    // If no chats are loaded, show sample data for testing
    if (_chats.isEmpty && _error == null) {
      setState(() {
        _chats = _getSampleChats();
        _isLoading = false;
      });
    }
  }

  List<Chat> _getSampleChats() {
    // Create sample chats for testing
    return [
      Chat(
        id: '1',
        user1: User(id: '1', name: 'Alex Linderson', email: 'alex@example.com'),
        user2: User(id: '2', name: 'You', email: 'you@example.com'),
      ),
      Chat(
        id: '2',
        user1: User(id: '3', name: 'Team Align', email: 'team@example.com'),
        user2: User(id: '2', name: 'You', email: 'you@example.com'),
      ),
      Chat(
        id: '3',
        user1: User(id: '4', name: 'John Ahraham', email: 'john@example.com'),
        user2: User(id: '2', name: 'You', email: 'you@example.com'),
      ),
      Chat(
        id: '4',
        user1: User(id: '5', name: 'Sabila Sayma', email: 'sabila@example.com'),
        user2: User(id: '2', name: 'You', email: 'you@example.com'),
      ),
    ];
  }

  void _onChatTap(Chat chat) {
    Navigator.pushNamed(
      context,
      ChatConversationPage.routeName,
      arguments: chat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51F3),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
            const SizedBox(width: 8),
            Text(
              'Chats',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Implement menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status/Stories section
          Container(
            color: const Color(0xFF3F51F3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: UserStatusList(),
          ),
          
          // Chat list section
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
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
              'Failed to load chats',
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
              onPressed: _loadChats,
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

    if (_chats.isEmpty) {
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
              'No chats yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with someone!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChats,
      color: const Color(0xFF3F51F3),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ChatListItem(
            chat: chat,
            onTap: () => _onChatTap(chat),
          );
        },
      ),
    );
  }
}
