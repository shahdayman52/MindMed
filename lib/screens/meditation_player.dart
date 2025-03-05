import 'package:flutter/material.dart';

class MeditationPlayerPage extends StatelessWidget {
  const MeditationPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF7D624F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
          ),
          Image.asset(
            'assets/images/meditation_image.png', // Replace with your meditation image
            width: 300,
            height: 250,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {}, // Add previous track logic
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Color(0xFF7D624F),
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {}, // Add play/pause logic
                  icon: const Icon(
                    Icons.play_circle_filled,
                    color: Color(0xFF7D624F),
                    size: 50,
                  ),
                ),
                IconButton(
                  onPressed: () {}, // Add next track logic
                  icon: const Icon(
                    Icons.skip_next,
                    color: Color(0xFF7D624F),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Add end session logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D624F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            ),
            child: const Text(
              'End Session',
              style: TextStyle(
                fontFamily: 'Onest',
                fontSize: 29,
                color: Color(0xFFEAE6E3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
