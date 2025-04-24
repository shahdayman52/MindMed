import 'package:flutter/material.dart';
import 'package:mindmed/services/notification_service.dart';
import 'chatbot_chat.dart';
import 'community.dart';
import 'moodflow.dart';
import 'navbar.dart';
import 'meditation_category.dart';
import 'JournalEntryScreen.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'HotlinesPage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  String username = '';
  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle bottom nav tap if needed
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// Header Row with Hello + Logout Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.phone,
                      color: Colors.brown,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HotlinesPage(),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      "MindMed",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout,size: 30,),
                    onPressed: () async {
                      await AuthService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false, // Remove all previous routes
                      );
                    },
                  )
                ],
              ),

              const SizedBox(height: 50),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello, $username!',
                    style: TextStyle(
                      fontFamily: 'Gayathri',
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF6C635D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: showInstantNotification,
                child: const Text("Send Test Notification"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MoodFlowScreen()),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Image.asset('assets/images/moodlogcard.png',
                      width: double.infinity,
                      height:
                          260, // 🍑 Try 170, 180, or 200 until it looks perfect
                      fit: BoxFit.fitWidth),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What would you like to do today?",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 25,
                      fontFamily: 'Gayathri',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 40), // Padding at start
                      _buildMiniCard(
                        context,
                        "Meditation",
                        'assets/images/cardMeditation.png',
                        const MeditationCategoryPage(),
                      ),
                      const SizedBox(width: 40),
                      _buildMiniCard(
                        context,
                        "Journal",
                        'assets/images/cardJournal.png',
                        JournalEntryScreen(onSave: (String t, String c) {}),
                      ),
                      const SizedBox(width: 40),
                      _buildMiniCard(
                        context,
                        "Community",
                        'assets/images/cardCommunity.png',
                        const CommunityPage(),
                      ),
                      const SizedBox(width: 40),
                      _buildMiniCard(
                        context,
                        "Chatbot",
                        'assets/images/cardChatbot.png',
                        const ChatScreen(),
                      ),
                      const SizedBox(width: 16), // Padding at end
                    ],
                  ),
                ),
                // GridView.count(
                //   physics: const NeverScrollableScrollPhysics(),
                //   shrinkWrap: true,
                //   crossAxisCount: 2,
                //   crossAxisSpacing: 10,
                //   mainAxisSpacing: 16,
                //   children: [
                //     _buildCard(
                //       context,
                //       "Journal",
                //       "assets/images/journalcardnew.png",
                //       JournalEntryScreen(
                //         onSave: (String title, String content) {},

                //       ),

                //     ),
                //     _buildCard(
                //       context,
                //       "Community",
                //       "assets/images/communityCard.png",
                //       const CommunityPage(),
                //     ),
                //         _buildCard(
                //       context,
                //       "Meditation",
                //       "assets/images/meditationCardnew2.png",
                //       const MeditationPage(),
                //     ),

                //     _buildCard(
                //       context,
                //       "Chatbot",
                //       "assets/images/chatbotCard.png",
                //       const ChatScreen(),
                //     ),
                //   ],
                // ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCard(
      BuildContext context, String title, String imagePath, Widget nextPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        width: 190, // adjust for cuteness
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
// Widget _buildCard(
//     BuildContext context, String title, String imagePath, Widget nextPage) {
//   return AspectRatio(
//     aspectRatio: 1, // Makes every card a perfect square
//     child: GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => nextPage),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(

//           borderRadius: BorderRadius.circular(20),
//           image: DecorationImage(
//             image: AssetImage(imagePath),
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     ),
//   );
//}
}
