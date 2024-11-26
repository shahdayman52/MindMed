import 'package:flutter/material.dart';
// import 'meditation_page.dart'; // Importing new pages
// import 'community_page.dart';
// import 'journal_page.dart';
// import 'chatbot_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF6C635D), size: 40),
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(
              "Hello, friend!",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: 'Gayathri',
                fontSize: 24,
                fontWeight: FontWeight.normal, // Non-italic
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),

      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              title: Text("Option 1"),
              onTap: () {},
            ),
            ListTile(
              title: Text("Option 2"),
              onTap: () {},
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
            // SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
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
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                // Navigate to mood logging page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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
                  SizedBox(width: 10),
                  Text(
                    "Log Your Mood Today !",
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
            SizedBox(height: 32),
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
                    HomePage(),
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
                    HomePage(),
                  ),
                  _buildCard(
                    context,
                    "Chatbot",
                    "assets/images/chatbotCard4.png",
                    HomePage(),
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
        // Navigate to the next page
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
