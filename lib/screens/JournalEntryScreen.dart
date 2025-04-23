// ignore: file_names
import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class JournalEntryScreen extends StatefulWidget {
  final Function(String title, String content)
      onSave; // 📤 Callback to pass entered data back
  final String? initialTitle; // 📝 For editing
  final String? initialContent;

  const JournalEntryScreen({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialContent,
  });

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  bool _isListeningForTitle = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // ✅ Set initial values for editing mode
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';

    _initSpeech();
  }

  // ✅ Initialize speech-to-text
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          _stopListening();
        }
      },
      onError: (error) => print('Error: $error'),
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  // ✅ Start listening for either title or content

  void _startListening({bool forTitle = false}) async {
    if (!_isListening) {
      _lastWords = '';
      _isListeningForTitle = forTitle;
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              if (_isListeningForTitle) {
                _titleController.text = _lastWords;
              } else {
                _contentController.text = _lastWords;
              }
            });
          },
        );
      }
    }
  }

  // ✅ Stop voice input
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle bottom nav tap if needed
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          "New Journal Entry",
          style: TextStyle(
            fontSize: 30,
            color: Color(0xFF7D624F),
            fontFamily: 'Gayathri',
          ),
        ),
        actions: [
          // ✅ On "Done", send data back to parent screen
          TextButton(
            onPressed: () {
              widget.onSave(
                _titleController.text.trim(),
                _contentController.text.trim(),
              );
              Navigator.of(context).pop();
            },
            child: Text(
              "Done",
              style: TextStyle(color: Colors.brown[800], fontSize: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Show today's date
            Text(
              DateTime.now().toLocal().toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 30,
                color: Color(0xFF7D624F),
                fontFamily: 'Gayathri',
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Title input with mic
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 30,
                      color: Color(0xFF7D624F),
                      fontFamily: 'Gayathri',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isListening && _isListeningForTitle
                        ? Icons.mic_off
                        : Icons.mic,
                    color: _isListening && _isListeningForTitle
                        ? Colors.red
                        : Colors.brown,
                  ),
                  onPressed: () {
                    if (_isListening && _isListeningForTitle) {
                      _stopListening();
                    } else {
                      if (_isListening) _stopListening();
                      _startListening(forTitle: true);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ Content input with mic
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: "Start writing...",
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      backgroundColor: _isListening && !_isListeningForTitle
                          ? Colors.red
                          : Colors.brown,
                      onPressed: () {
                        if (_isListening && !_isListeningForTitle) {
                          _stopListening();
                        } else {
                          if (_isListening) _stopListening();
                          _startListening(forTitle: false);
                        }
                      },
                      child: Icon(
                        _isListening && !_isListeningForTitle
                            ? Icons.stop
                            : Icons.mic,
                        color: Colors.white,
                      ),
                      mini: true,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Optional status
            if (_isListening)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _isListening ? 'Listening...' : 'Not listening',
                  style: const TextStyle(color: Colors.brown),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
