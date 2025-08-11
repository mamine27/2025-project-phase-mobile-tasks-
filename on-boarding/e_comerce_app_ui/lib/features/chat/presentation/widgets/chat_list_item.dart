import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final Message? lastMessage;
  final int unreadCount;
  final String? lastMessageTime;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageTime,
  });

  String _getDisplayName() {
    // For now, show the other user's name
    // In a real app, you'd determine which user is the current user
    return chat.user1.name.isNotEmpty ? chat.user1.name : chat.user2.name;
  }

  String _getLastMessageText() {
    if (lastMessage != null) {
      return lastMessage!.content;
    }
    // Default message if no last message
    return 'Start a conversation!';
  }

  String _getLastMessageTime() {
    if (lastMessageTime != null) {
      return lastMessageTime!;
    }
    return '2 min ago'; // Default time
  }

  Color _getAvatarColor(String userId) {
    // Generate a consistent color based on user ID
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    final index = userId.hashCode % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final lastMessageText = _getLastMessageText();
    final lastMessageTime = _getLastMessageTime();
    final avatarColor = _getAvatarColor(chat.id);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageTime,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51F3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
