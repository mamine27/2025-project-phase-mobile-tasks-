import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button
            IconButton(
              onPressed: () {
                // TODO: Implement attachment functionality
              },
              icon: const Icon(
                Icons.attach_file,
                color: Color(0xFF3F51F3),
              ),
            ),
            
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isSending,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Write your message',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Emoji button
            IconButton(
              onPressed: () {
                // TODO: Implement emoji picker
              },
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: Color(0xFF3F51F3),
              ),
            ),
            
            // Camera button
            IconButton(
              onPressed: () {
                // TODO: Implement camera functionality
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF3F51F3),
              ),
            ),
            
            // Send/Microphone button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3F51F3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

