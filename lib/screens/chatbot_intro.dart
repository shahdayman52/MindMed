import 'package:flutter/material.dart';
import 'chatbot_chat.dart';
import 'homepage.dart';



// Screen 1: Welcome Screen
class ChatbotIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new , color: Colors.black54),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text(
          'MindMed',
          style: TextStyle(
            fontFamily: 'Onest',
            fontSize: 24,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle : true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          // Enlarged Robot Image (without blue border)
          Center(
            child: Image.asset(
              'assets/images/chatbot.png', // Replace with your robot image path
              width: 330, // Increased size
              height: 330,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Hola, I’m Neura',
           style: TextStyle(
              fontFamily: 'Onest',
              fontSize: 29,
              color: Color(0xFF6C635D),
            ),
          ),
          Spacer(),
          // Updated Get Started Button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 70), // Adjusted width
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEAE6E3), // Fixed primary color
                foregroundColor: Colors.white, // Fixed onPrimary color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Onest',
                      fontSize: 29,
                      color: Color(0xFF6C635D),
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.arrow_forward_ios_outlined ,color: Color(0xFF6C635D),),
                ],
              ),
            ),
          ),
          SizedBox(height: 120), // Adjusted button position
        ],
      ),
    );
  }
}
