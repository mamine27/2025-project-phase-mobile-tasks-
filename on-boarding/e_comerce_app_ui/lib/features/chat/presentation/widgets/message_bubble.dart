import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMyMessage 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMyMessage 
                    ? const Color(0xFF3F51F3)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isMyMessage ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMyMessage ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isMyMessage ? 0 : 16,
                right: isMyMessage ? 16 : 0,
              ),
              child: Text(
                _formatTime(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case 'text':
        return Text(
          message.content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isMyMessage ? Colors.white : Colors.black87,
          ),
        );
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      case 'audio':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: isMyMessage ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: isMyMessage 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 2,
                    height: (index + 1) * 3.0,
                    decoration: BoxDecoration(
                      color: isMyMessage ? Colors.white : Colors.grey[600],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '00:16',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isMyMessage ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        );
      default:
        return Text(
          message.content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isMyMessage ? Colors.white : Colors.black87,
          ),
        );
    }
  }

  String _formatTime() {
    // For now, return a default time
    // In a real app, you'd parse the message timestamp
    return '09:25 AM';
  }
}

