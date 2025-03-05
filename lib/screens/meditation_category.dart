import 'package:flutter/material.dart';
import 'VRSessionPage.dart';

class MeditationCategoryPage extends StatelessWidget {
  const MeditationCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Meditation',
              style: TextStyle(
                color: Color(0xFF7D624F),
                fontFamily: 'Gayathri',
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildCategoryTile(
                    context, 'Wind', 'assets/images/beigecard.png'),
                _buildCategoryTile(
                    context, 'Rain', 'assets/images/browncard.png'),
                _buildCategoryTile(
                    context, 'ASMR', 'assets/images/pinkcard.png'),
                _buildCategoryTile(
                    context, 'Grass', 'assets/images/orangecard.png'),
                _buildCategoryTile(
                    context, 'River', 'assets/images/beigecard.png'),
                _buildCategoryTile(
                    context, 'Waves', 'assets/images/browncard.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
      BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VRSessionPage(category: title),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 300,
            minHeight: 250,
            minWidth: 150,
            maxWidth: 200,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7D624F),
                    fontSize: 20,
                    fontFamily: 'Gayathri',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
