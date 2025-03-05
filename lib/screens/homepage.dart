import 'package:flutter/material.dart';
import 'meditation_intro.dart';
// import 'community_page.dart';
import 'JournalEntryScreen.dart';
import 'chatbot_intro.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // String nickname = '';

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF6C635D), size: 40),
        automaticallyImplyLeading: false,
        title: Text("Hello User") ,
      ),


      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF6C635D),
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height:5 ), // Add space at the top
                  Text(
                    "user" ,// Display the nickname
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white, // Set background color to white
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text("Home"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text("Chatbot"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.self_improvement),
                      title: const Text("Meditation"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text("Journal"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text("Community"),
                      onTap: () {},
                    ),
                    const Spacer(), // Pushes the settings tile to the bottom
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () {},
                      tileColor:
                          Colors.white, // Set background of settings to white
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Set background color to white (FFFFFF)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            // Text(
            //   "Hello, User!",
            //   style: const TextStyle(
            //     fontFamily: 'Gayathri',
            //     fontSize: 24,
            //     fontWeight: FontWeight.normal, // Non-italic
            //     color: Colors.black54,
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Keep\nYour Mind\nClear",
                style: TextStyle(
                  fontFamily: 'Gayathri',
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: Color(0xFF6C635D),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                    "Log Your Mood Today clicked!",
                    style: TextStyle(
                      fontFamily: 'Gayathri',
                    ),
                  )),
                );
              },
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    "Log Your Mood Today!",
                    style: TextStyle(
                      fontFamily: 'Gayathri',
                      fontSize: 26,
                      decoration: TextDecoration.underline,
                      color: Color(0xFF6C635D),
                    ),
                  ),
                  Image.asset(
                    'assets/images/calendarCard.png', // Add your calendar image here
                    height: 92,
                    width: 99,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(
                    context,
                    "Meditation",
                    "assets/images/meditationCard1.png",
                    MeditationPage(),
                  ),
                  _buildCard(
                    context,
                    "Community",
                    "assets/images/communityCard2.png",
                    HomePage(),
                  ),
                  _buildCard(
                    context,
                    "Journal",
                    "assets/images/journalCard3.png",
                    JournalEntryScreen(onSave: (String title, String content) {  },),
                  ),
                  _buildCard(
                    context,
                    "Chatbot",
                    "assets/images/chatbotCard4.png",
                    ChatbotIntro(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String imagePath, Widget nextPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
