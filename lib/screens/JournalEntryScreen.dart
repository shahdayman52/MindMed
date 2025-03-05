import 'package:flutter/material.dart';

class JournalEntryScreen extends StatefulWidget {
  final Function(String title, String content) onSave;
  final String? initialTitle;
  final String? initialContent;

  const JournalEntryScreen(
      {super.key,
      required this.onSave,
      this.initialTitle,
      this.initialContent});

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          "New Journal Entry",
          style: TextStyle(
              fontSize: 30, color: Color(0xFF7D624F), fontFamily: 'Gayathri'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(
                  _titleController.text.trim(), _contentController.text.trim());
              Navigator.of(context).pop();
            },
            child: Text("Done",
                style: TextStyle(color: Colors.brown[800], fontSize: 20)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateTime.now().toLocal().toString().split(' ')[0],
              style: const TextStyle(
                  fontSize: 30,
                  color: Color(0xFF7D624F),
                  fontFamily: 'Gayathri'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  hintText: "Title", border: InputBorder.none),
              style: const TextStyle(
                  fontSize: 30,
                  color: Color(0xFF7D624F),
                  fontFamily: 'Gayathri'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                    hintText: "Start writing...", border: InputBorder.none),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
