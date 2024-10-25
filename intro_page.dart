import 'dart:async';
import 'package:flutter/material.dart';
import 'register_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _showFirstText = true;

  @override
  void initState() {
    super.initState();

    // Show first text for 3 seconds, then change to second text
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showFirstText = false;
      });
    });

    // Navigate to RegisterPage after 6 seconds
    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/intro_background2.png'), // Your background image
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: Stack(
          children: [
            // Text for "Mindmed" at the top left
            const Positioned(
              top: 40, // Adjust the top position as needed
              left: 20, // Adjust the left position as needed
              child: Text(
                'Mindmed',
                style: TextStyle(
                  fontSize: 22, // Adjust the font size as needed
                  fontWeight: FontWeight.w300, // Make it bold
                  color: Colors.black, // Text color
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/intro.png',
                    width: 300,
                    height: 400,
                  ), // Your image in assets
                  const SizedBox(height: 10),
                  Text(
                    _showFirstText ? 'You are loved..' : 'Breathe..',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF0f868b), // Text color
                    ),
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
