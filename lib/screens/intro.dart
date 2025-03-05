import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'homepage.dart';



class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 182, 168, 159), // Light brown background
      body: Column(
        children: [
          // Logo with text
          Padding(
            padding: const EdgeInsets.only(top: 100.0, bottom: 30.0),
            child: Image.asset(
              'assets/images/intro.png', // Replace with the path to your logo image
              width: 400, // Adjust size if needed
            ),
          ),
          // White container that takes up the rest of the screen
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // "Your Journey Starts Here" text
                    Text(
                      'Your Journey \n Starts Here',
                      style: TextStyle(
                        fontFamily: 'Gayathri',
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBBA79C), // Text color
                      ),
                    ),
                    SizedBox(height: 20),
                    // Register button
                    SizedBox(
                      width: 190,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Color(0xFF8D6E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Register()),
            );
          },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF8D6E63),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Login button
                    SizedBox(
                      width: 190,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Color(0xFF8D6E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF8D6E63),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
