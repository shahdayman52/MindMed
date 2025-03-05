import 'package:flutter/material.dart';
import 'homepage.dart';

class StressQuestionPage extends StatefulWidget {
  const StressQuestionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StressQuestionPageState createState() => _StressQuestionPageState();
}

class _StressQuestionPageState extends State<StressQuestionPage> {
  int _selectedStressLevel = 0;

  void _selectStressLevel(int level) {
    setState(() {
      _selectedStressLevel = level;
    });
  }

  void _submit() {
    // Navigate directly to HomePage when 'Continue' is pressed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'MindMed',
              style: TextStyle(
                fontFamily: 'Onest',
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6C635D),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60.0),
            const Text(
              'On a scale from 1 to 10, how stressed do you feel today?',
              style: TextStyle(
                fontSize: 24.0,
                fontFamily: 'Gayathri',
                color: Color(0xFF6C635D),
              ),
            ),
            const SizedBox(height: 40.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 50.0,
              runSpacing: 30.0,
              children: List.generate(10, (index) {
                int level = index + 1;
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 230) / 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedStressLevel == level
                          ? const Color.fromARGB(255, 232, 229, 229)
                          : const Color.fromARGB(176, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => _selectStressLevel(level),
                    child: Text(
                      level.toString(),
                      style: const TextStyle(
                        color: Color(0xFF6C635D),
                        fontSize: 18,
                        fontFamily: 'Onest',
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 50.0),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 190,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(199, 255, 255, 255),
                    side: const BorderSide(color: Color(0xFF6C635D), width: 1),
                    minimumSize: const Size(double.infinity, 55),
                    elevation: 5,
                    shadowColor: const Color(0xFFFFFAF4),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF6C635D),
                      fontFamily: 'Onest',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
