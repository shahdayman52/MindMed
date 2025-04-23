import 'package:flutter/material.dart';
import 'moodlog.dart'; // Your MoodLoggingPage file
import 'mood_dashboard.dart'; // Your MoodDashboard file

class MoodFlowScreen extends StatefulWidget {
  const MoodFlowScreen({super.key});

  @override
  State<MoodFlowScreen> createState() => _MoodFlowScreenState();
}

class _MoodFlowScreenState extends State<MoodFlowScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: _currentIndex == index ? 20 : 10,
          decoration: BoxDecoration(
            color: _currentIndex == index ? Colors.brown : Colors.brown[200],
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        onPageChanged: onPageChanged,
        children: const [
          MoodLoggingPage(),
          MoodDashboard(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: buildDots(),
      ),
    );
  }
}
