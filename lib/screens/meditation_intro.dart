import 'package:flutter/material.dart';
import 'meditation_category.dart';
import 'homepage.dart';


class MeditationPage extends StatelessWidget {
  const MeditationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFAF4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new , color: Colors.black54),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),),
      backgroundColor: const Color(0xFFFFFAF4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Meditation',
              style: TextStyle(
                  fontSize: 40,
                  color: Color(0xFF7D624F),
                  fontFamily: 'Gayathri'),
            ),
            Image.asset(
              'assets/images/meditationintro.png',
              width: 350,
            ),
            const SizedBox(height: 20),
            const Text(
              'Take a deep breath and let\'s start meditating',
              style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF7D624F),
                  fontFamily: 'Gayathri'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200, // Set button width
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeditationCategoryPage()),
                );
              },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFAF4), // Reduced opacity
                  side: const BorderSide(
                    color: Color.fromARGB(255, 230, 228, 227),
                    width: 1,
                  ), // Brown border
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFFFFFAF4), // Set button height
                ),
                child: const Text(
                  style: TextStyle(fontSize: 20, color: Color(0xFF7D624F)),
                  'Get Started    >',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
