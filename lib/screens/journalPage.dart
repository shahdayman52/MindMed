import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'JournalEntryScreen.dart';
import 'homepage.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<Map<String, dynamic>> journalEntries = [];

  // This function predicts the mental health status using the API
  Future<String> _predictMentalHealthStatus(String content) async {
    const String apiUrl =
        'http://127.0.0.1:5001/predict'; // Localhost API endpoint
    const String apiKey =
        '2qPHzBAML1ICY5TpNDScAt3Rz2o_6Mj51tGzXY7XhPfGfiQTi'; // Replace with your API Key

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({'text': content}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['prediction'] ?? 'Unknown';
      } else {
        throw Exception(
            'Failed to predict mental health status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');
      return 'Error';
    }
  }

  // Adds a new journal entry with prediction
  void _addJournal(String title, String content) async {
    String predictedStatus = await _predictMentalHealthStatus(content);
    String date = DateTime.now().toLocal().toString().split(' ')[0];
    setState(() {
      journalEntries.add({
        'title': title,
        'content': content,
        'date': date,
        'status': predictedStatus,
      });
    });
  }

  // Edits an existing journal entry with prediction
  void _editJournal(int index, String title, String content) async {
    String predictedStatus = await _predictMentalHealthStatus(content);
    String date = DateTime.now().toLocal().toString().split(' ')[0];
    setState(() {
      journalEntries[index] = {
        'title': title,
        'content': content,
        'date': date,
        'status': predictedStatus,
      };
    });
  }

  // Deletes a journal entry
  void _deleteJournal(int index) {
    setState(() {
      journalEntries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: null, // Disable the default leading widget
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black54,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
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
                  Image.asset(
                    'assets/images/journal.png',
                    width: 400,
                  ),
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
                        Text(journalEntries[index]['content'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14)),
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
                        if (value == 'edit') {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => JournalEntryScreen(
                                        onSave: (title, content) =>
                                            _editJournal(index, title, content),
                                        initialTitle: journalEntries[index]
                                            ['title'],
                                        initialContent: journalEntries[index]
                                            ['content'],
                                      )))
                              .then((_) => setState(() {}));
                        } else if (value == 'delete') {
                          _deleteJournal(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.brown),
                              SizedBox(width: 10),
                              Text("Edit"),
                            ],
                          ),
                        ),
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
                          onSave: (title, content) =>
                              _addJournal(title, content),
                        )))
                .then((_) => setState(() {}));
          },
          backgroundColor: Colors.brown,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}
