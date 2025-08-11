import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStatusList extends StatelessWidget {
  const UserStatusList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // My status
              _buildStatusItem(
                name: 'My status',
                avatarColor: Colors.white,
                isMyStatus: true,
                onTap: () {
                  // TODO: Implement add status functionality
                },
              ),
              const SizedBox(width: 16),
              
              // Sample users (in a real app, these would come from API)
              _buildStatusItem(
                name: 'Adil',
                avatarColor: Colors.green,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              
              _buildStatusItem(
                name: 'Marina',
                avatarColor: Colors.pink,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              
              _buildStatusItem(
                name: 'Dean',
                avatarColor: Colors.blue,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              
              _buildStatusItem(
                name: 'Max',
                avatarColor: Colors.orange,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String name,
    required Color avatarColor,
    bool isMyStatus = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: isMyStatus
                ? const Icon(
                    Icons.add,
                    color: Color(0xFF3F51F3),
                    size: 24,
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isMyStatus ? const Color(0xFF3F51F3) : Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

