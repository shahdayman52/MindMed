import 'package:flutter/material.dart';
import 'navbar.dart';
import 'meditation_player.dart';

class MeditationCategoryPage extends StatelessWidget {
  const MeditationCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation if needed
        },
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Find your calm.',
              style: TextStyle(
                color: Color(0xFF4B3621),
                fontFamily: 'Gayathri',
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose a sound to begin',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontFamily: 'Gayathri',
              ),
            ),
          
            SizedBox(
              child: Center(
                child: SizedBox(
                  width: 380,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    children: [
                      _buildCategoryTile(
                        context,
                        'assets/images/wind.png',
                        'https://youtu.be/e_a3j_0nflI',
                      ),
                      _buildCategoryTile(
                        context,
                        'assets/images/rain.png',
                        'https://youtu.be/1ZYbU82GVz4',
                      ),
                      _buildCategoryTile(
                        context,
                        'assets/images/river.png',
                        'https://youtu.be/4Rj8E3ZxD4o',
                      ),
                      _buildCategoryTile(
                        context,
                        'assets/images/waves.png',
                        'https://youtu.be/5a6o0gD9E8M',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
      BuildContext context, String imagePath, String videoUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeditationVideoPage(
              videoUrl: videoUrl,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
