import 'package:flutter/material.dart';
import 'questionaire.dart'; 
import 'stress_question.dart';
class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What kind of guidance are you looking for?',
      'answers': [
        'Calming',
        'Exercises',
        'Daily Reminders',
        'Inspirational Quotes',
      ],
    },
    {
      'question': 'Are there any areas you\'d like help with?',
      'answers': ['Anxiety', 'Stress', 'Sleep', 'Mood'],
    },
    {
      'question': 'Have you been anxious or overwhelmed lately?',
      'answers': ['Not at all', 'Rarely', 'Often', 'A lot'],
    },
    {
      'question': 'How often have you felt happy or at peace this week?',
      'answers': ['Not at all', 'Rarely', 'Often', 'A lot'],
    },
    {
      'question':
          'Are mornings, afternoon or evenings a better time for you to check in with the App?',
      'answers': ['Mornings', 'Afternoons', 'Evenings', 'Randomly'],
    },
  ];

  void _nextQuestion(String selectedAnswer) {
    // Move to the next question or navigate to the StressQuestionPage after the last question
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StressQuestionPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
              backgroundColor: Colors.white,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            const Text(
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60.0),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: const TextStyle(fontSize: 24.0, fontFamily: 'Gayathri'),
            ),
            const SizedBox(height: 60.0),
            ..._questions[_currentQuestionIndex]['answers']
                .asMap()
                .entries
                .map<Widget>((entry) {
              int index = entry.key;
              String answer = entry.value;
              Color buttonColor;
              switch (index) {
                case 0:
                  buttonColor = const Color(0xFFE8C795);
                  break;
                case 1:
                  buttonColor = const Color(0xFFD7A68D);
                  break;
                case 2:
                  buttonColor = const Color(0xFFD3A6A1);
                  break;
                case 3:
                  buttonColor = const Color(0xFFB8A89D);
                  break;
                default:
                  buttonColor = Colors.blue;
              }
              return Column(
                children: [
                  SizedBox(
                    width: 360,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () => _nextQuestion(answer),
                      child: Text(
                        answer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
