import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class JournalEntryScreen extends StatefulWidget {
  final Function(String title, String content) onSave;
  final String? initialTitle;
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
  bool _speechSupported = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' && _isListening) {
            _stopListening();
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (!available) {
        setState(() => _speechSupported = false);
        print('🚫 Speech recognition not available.');
      }
    } catch (e) {
      print('💥 Speech initialization failed: $e');
      setState(() => _speechSupported = false);
    }
  }

  Future<void> _startListening({bool forTitle = false}) async {
    try {
      if (!_isListening && _speechSupported) {
        print('🔍 Requesting mic permission...');
        var status = await Permission.microphone.request();

        if (!status.isGranted) {
          print('🚫 Mic permission denied');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Permission Denied"),
              content: const Text(
                  "Please enable microphone permission to use voice input."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Settings"),
                ),
              ],
            ),
          );
          return;
        }

        _lastWords = '';
        _isListeningForTitle = forTitle;

        print('🧠 Initializing speech...');
        bool available = await _speech.initialize();
        if (available) {
          print('✅ Speech initialized. Listening...');
          setState(() {
            _isListening = true;
          });
          _speech.listen(
            onResult: (result) {
              print('🎤 Heard: ${result.recognizedWords}');
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
        } else {
          print('❌ Speech recognition not available.');
          setState(() => _speechSupported = false);
        }
      }
    } catch (e) {
      print('💥 ERROR in _startListening: $e');
      setState(() => _speechSupported = false);
    }
  }

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
      bottomNavigationBar: BottomNavBar(currentIndex: 4, onTap: (_) {}),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "New Journal Entry",
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Serif',
            color: Color(0xFF7D624F),
          ),
        ),
        actions: [
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
              style: TextStyle(
                color: Colors.brown[800],
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTime.now().toLocal().toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'Sans',
                    color: Color(0xFF7D624F),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFDBB6A2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: "Title",
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              color: Color(0xFF7D624F),
                              fontFamily: 'Sans',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isListening && _isListeningForTitle
                              ? Icons.mic_off
                              : Icons.mic,
                          color: _speechSupported ? Colors.brown : Colors.grey,
                        ),
                        onPressed: _speechSupported
                            ? () {
                                if (_isListening && _isListeningForTitle) {
                                  _stopListening();
                                } else {
                                  if (_isListening) _stopListening();
                                  _startListening(forTitle: true);
                                }
                              }
                            : null,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (!_speechSupported)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "⚠️ Voice input not supported on this device.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFDBB6A2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: "Start writing...",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF7D624F),
                        fontFamily: 'Sans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                if (_isListening)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Listening...',
                        style: const TextStyle(color: Colors.brown),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: _speechSupported
                  ? (_isListening && !_isListeningForTitle
                      ? Colors.red
                      : Colors.brown)
                  : Colors.grey,
              onPressed: _speechSupported
                  ? () {
                      if (_isListening && !_isListeningForTitle) {
                        _stopListening();
                      } else {
                        if (_isListening) _stopListening();
                        _startListening(forTitle: false);
                      }
                    }
                  : null,
              child: Icon(
                _isListening && !_isListeningForTitle ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'navbar.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';

// class JournalEntryScreen extends StatefulWidget {
//   final Function(String title, String content) onSave;
//   final String? initialTitle;
//   final String? initialContent;

//   const JournalEntryScreen({
//     super.key,
//     required this.onSave,
//     this.initialTitle,
//     this.initialContent,
//   });

//   @override
//   _JournalEntryScreenState createState() => _JournalEntryScreenState();
// }

// class _JournalEntryScreenState extends State<JournalEntryScreen> {
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _lastWords = '';
//   bool _isListeningForTitle = false;
//   bool _speechSupported = true;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _titleController.text = widget.initialTitle ?? '';
//     _contentController.text = widget.initialContent ?? '';
//     _initSpeech();
//   }

//   void _initSpeech() async {
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         if (status == 'done' && _isListening) {
//           _stopListening();
//         }
//       },
//       onError: (error) => print('Error: $error'),
//     );

//     if (!available) {
//       setState(() => _speechSupported = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Speech recognition not available')),
//       );
//     }
//   }

//   Future<void> _startListening({bool forTitle = false}) async {
//     try {
//       if (!_isListening) {
//         print('🔍 Requesting mic permission...');
//         var status = await Permission.microphone.request();

//         if (!status.isGranted) {
//           print('🚫 Mic permission denied');
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Permission Denied"),
//               content: const Text(
//                   "Please enable microphone permission to use voice input."),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("OK"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     openAppSettings();
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("Settings"),
//                 ),
//               ],
//             ),
//           );
//           return;
//         }

//         _lastWords = '';
//         _isListeningForTitle = forTitle;

//         print('🧠 Initializing speech...');
//         bool available = await _speech.initialize();
//         if (available) {
//           print('✅ Speech initialized. Listening...');
//           setState(() {
//             _isListening = true;
//             _speechSupported = true;
//           });
//           _speech.listen(
//             onResult: (result) {
//               print('🎤 Heard: ${result.recognizedWords}');
//               setState(() {
//                 _lastWords = result.recognizedWords;
//                 if (_isListeningForTitle) {
//                   _titleController.text = _lastWords;
//                 } else {
//                   _contentController.text = _lastWords;
//                 }
//               });
//             },
//           );
//         } else {
//           print('❌ Speech recognition not available on this device');
//           setState(() => _speechSupported = false);
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Speech Not Supported"),
//               content: const Text(
//                   "Your device does not support speech recognition."),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('💥 ERROR in _startListening: $e');
//     }
//   }

//   void _stopListening() {
//     if (_isListening) {
//       _speech.stop();
//       setState(() => _isListening = false);
//     }
//   }

//   @override
//   void dispose() {
//     _speech.stop();
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       bottomNavigationBar: BottomNavBar(currentIndex: 4, onTap: (_) {}),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "New Journal Entry",
//           style: TextStyle(
//             fontSize: 28,
//             fontFamily: 'Serif',
//             color: Color(0xFF7D624F),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               widget.onSave(
//                 _titleController.text.trim(),
//                 _contentController.text.trim(),
//               );
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               "Done",
//               style: TextStyle(
//                 color: Colors.brown[800],
//                 fontSize: 18,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   DateTime.now().toLocal().toString().split(' ')[0],
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontFamily: 'Sans',
//                     color: Color(0xFF7D624F),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFFBF5),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Color(0xFFDBB6A2)),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: TextField(
//                             controller: _titleController,
//                             decoration: const InputDecoration(
//                               hintText: "Title",
//                               border: InputBorder.none,
//                             ),
//                             style: const TextStyle(
//                               fontSize: 22,
//                               color: Color(0xFF7D624F),
//                               fontFamily: 'Sans',
//                             ),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           _isListening && _isListeningForTitle
//                               ? Icons.mic_off
//                               : Icons.mic,
//                           color: Colors.brown,
//                         ),
//                         onPressed: () {
//                           if (_isListening && _isListeningForTitle) {
//                             _stopListening();
//                           } else {
//                             if (_isListening) _stopListening();
//                             _startListening(forTitle: true);
//                           }
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (!_speechSupported)
//                   const Padding(
//                     padding: EdgeInsets.only(left: 8.0),
//                     child: Text(
//                       "⚠️ Voice input not supported on this device.",
//                       style: TextStyle(color: Colors.redAccent, fontSize: 14),
//                     ),
//                   ),
//                 const SizedBox(height: 16),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFFBF5),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Color(0xFFDBB6A2)),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: TextField(
//                       controller: _contentController,
//                       decoration: const InputDecoration(
//                         hintText: "Start writing...",
//                         border: InputBorder.none,
//                       ),
//                       maxLines: null,
//                       keyboardType: TextInputType.multiline,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Color(0xFF7D624F),
//                         fontFamily: 'Sans',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 100),
//                 if (_isListening)
//                   Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Text(
//                         'Listening...',
//                         style: const TextStyle(color: Colors.brown),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: FloatingActionButton(
//               backgroundColor: _isListening && !_isListeningForTitle
//                   ? Colors.red
//                   : Colors.brown,
//               onPressed: () {
//                 if (_isListening && !_isListeningForTitle) {
//                   _stopListening();
//                 } else {
//                   if (_isListening) _stopListening();
//                   _startListening(forTitle: false);
//                 }
//               },
//               child: Icon(
//                 _isListening && !_isListeningForTitle ? Icons.stop : Icons.mic,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
