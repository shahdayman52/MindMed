import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'homepage.dart';
import 'meditation_category.dart';
import 'community.dart';
import 'chatbot_chat.dart';
import 'JournalEntryScreen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _navigateToPage(int index, BuildContext context) {
    Widget page;
    switch (index) {
      case 0:
        page = const MeditationCategoryPage();
        break;
      case 1:
        page = const CommunityPage();
        break;
      case 2:
        page = const HomePage(); // Center Home
        break;
      case 3:
        page = ChatScreen();
        break;
      case 4:
        page = JournalEntryScreen(onSave: (title, content) {});
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
  //  final icons = [
  //     LucideIcons.heart,
  //     LucideIcons.users,
  //     LucideIcons.home,
  //     LucideIcons.messageCircle,
  //     LucideIcons.bookOpen,
  //   ];
    final icons = [
      Icons.spa_outlined, // Meditation
      Icons.groups_2_outlined, // Community
      Icons.home_outlined, // Home
      Icons.chat_bubble_outline, // Chatbot
      Icons.menu_book_outlined, // Journal
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () {
              onTap(index);
              _navigateToPage(index, context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.brown.withOpacity(0.1),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                icons[index],
                size: isSelected ? 30 : 24,
                color: Colors.brown,
              ),
            ),
          );
        }),
      ),
    );
  }
}
