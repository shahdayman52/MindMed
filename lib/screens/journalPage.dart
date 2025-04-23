import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homepage.dart';
import 'navbar.dart';
import '../services/auth_service.dart';
import 'JournalEntryScreen.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<Map<String, dynamic>> journalEntries = [];

  @override
  void initState() {
    super.initState();
    fetchJournalEntries();
  }

  Future<void> fetchJournalEntries() async {
    try {
      final entries = await AuthService.getMyJournals();
      setState(() {
        journalEntries = entries.map((entry) {
          return {
            '_id': entry['_id'],
            'title': entry['title'],
            'content': entry['content'],
            'date': entry['date'].toString().split('T')[0],
            'status': entry['sentiment'],
          };
        }).toList();
      });
    } catch (e) {
      print("❌ Failed to load journals: $e");
    }
  }

  Future<String> _predictMentalHealthStatus(String content) async {
    final String apiUrl = 'http://localhost:5002/predict';
    const String apiKey = '2qPHzBAML1ICY5TpNDScAt3Rz2o_6Mj51tGzXY7XhPfGfiQTi';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({'text': content}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['prediction'] != null) {
        return data['prediction'];
      } else {
        print("❌ Prediction Error: ${data['error'] ?? 'Unknown error'}");
        return 'Error';
      }
    } catch (e) {
      print('❌ API Exception: $e');
      return 'Error';
    }
  }

  void _addJournal(String title, String content) async {
    print("📤 Predicting sentiment...");
    String predictedStatus = await _predictMentalHealthStatus(content);
    print("🔮 Prediction result: $predictedStatus");

    if (predictedStatus == 'Error') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ Sentiment prediction failed. Please try again."),
      ));
      return;
    }

    final response =
        await AuthService.saveJournal(title, content, predictedStatus);

    print("📥 Save response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      setState(() {
        journalEntries.add({
          '_id': responseData['_id'],
          'title': title,
          'content': content,
          'date': responseData['date'].toString().split('T')[0],
          'status': predictedStatus,
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Failed to save journal: ${response.body}"),
      ));
    }
  }

  void _deleteJournal(int index) async {
    final id = journalEntries[index]['_id'];
    await AuthService.deleteJournal(id);
    setState(() {
      journalEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle bottom nav tap if needed
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black54, size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Journal',
                style: TextStyle(
                  fontSize: 35,
                  color: Color(0xFF7D624F),
                  fontFamily: 'Gayathri',
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: journalEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  Image.asset('assets/images/journal.png', width: 400),
                  const SizedBox(height: 50),
                  const Text(
                    "Start Journaling",
                    style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF7D624F),
                        fontFamily: 'Gayathri'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create your personal journal.\nTap the plus button to get started.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        color: Color(0xFF7D624F),
                        fontFamily: 'Gayathri'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: journalEntries.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  color: const Color(0xFFFFFFFF),
                  child: ListTile(
                    title: Text(journalEntries[index]['title'] ?? '',
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journalEntries[index]['content'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          journalEntries[index]['date'] ?? '',
                          style:
                              TextStyle(fontSize: 12, color: Colors.brown[600]),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Status: ${journalEntries[index]['status']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.brown[800]),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteJournal(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (context) => JournalEntryScreen(
                    onSave: (title, content) => _addJournal(title, content),
                  ),
                ))
                .then((_) => fetchJournalEntries());
          },
          backgroundColor: Colors.brown,
          child: const Icon(Icons.add, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
