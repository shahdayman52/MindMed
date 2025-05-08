import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  bool _isListening = false;
  final Map<int, String> _feedback = {};

  static const apiKey = "AIzaSyA0p26b2muJvm3mEkY9wPra6JvHZbzw-cY";
  final model =
      GenerativeModel(model: 'models/gemini-2.0-flash', apiKey: apiKey);

  late Box _messageBox;
  final List<Message> _messages = [];

  late AnimationController _typingController;
  late Animation<double> _dotAnimation;

  final List<String> _suggestions = [
    "I feel anxious",
    "Help me sleep",
    "Give me a calming tip",
    "I’m feeling overwhelmed"
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _dotAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initHive() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    if (!Hive.isBoxOpen('messages')) {
      _messageBox = await Hive.openBox('messages');
    } else {
      _messageBox = Hive.box('messages');
    }

    setState(() {
      _messages.addAll(_messageBox.values
          .map((e) => Message.fromMap(Map<String, dynamic>.from(e)))
          .toList());
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _userInput.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _exportChat() async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/mindmed_chat_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(path);

    final content = _messages
        .map((m) =>
            '${m.isUser ? "You" : "AI"} [${DateFormat('MMM d, hh:mm a').format(m.date)}]: ${m.message}')
        .join('\n\n');

    await file.writeAsString(content);
    Share.shareXFiles([XFile(path)], text: 'MindMed Chat Export');
  }

  Future<void> sendMessage() async {
    final message = _userInput.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      final newMessage = Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      );
      _messages.add(newMessage);
      _messageBox.add(newMessage.toMap());
    });
    _scrollToBottom();

    try {
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        _isLoading = false;
        final aiMessage = Message(
          isUser: false,
          message: response.text ?? "No response received",
          date: DateTime.now(),
        );
        _messages.add(aiMessage);
        _messageBox.add(aiMessage.toMap());
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _rateMessage(int index, String rating) {
    setState(() {
      _feedback[index] = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Calm Talk',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 22,
            color: Colors.brown,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.brown),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messageBox.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.brown),
            onPressed: _messages.isEmpty ? null : _exportChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      final dots = '.' * (_dotAnimation.value.round() + 1);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Typing$dots',
                            style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black45),
                          ),
                        ),
                      );
                    }

                    final msg = _messages[index];
                    final formattedDate =
                        DateFormat('hh:mm a').format(msg.date);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Align(
                        alignment: msg.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: msg.isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? const Color(0xFFD8C5B8)
                                    : const Color(0xFFF1ECE6),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: msg.isUser
                                  ? Text(
                                      msg.message,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    )
                                  : MarkdownBody(
                                      data: msg.message,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 5),
                            Text(formattedDate,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: Text(_suggestions[index]),
                        backgroundColor: const Color(0xFFF1ECE6),
                        labelStyle: const TextStyle(color: Colors.black87),
                        onPressed: () {
                          _userInput.text = _suggestions[index];
                          sendMessage();
                          _userInput.clear();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.redAccent),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _userInput,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type how you’re feeling…',
                      hintStyle:
                          const TextStyle(fontSize: 18, color: Colors.black45),
                      filled: true,
                      fillColor: const Color(0xFFF1ECE6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded,
                      size: 32, color: Color(0xFFD8C5B8)),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_userInput.text.trim().isNotEmpty) {
                            sendMessage();
                            _userInput.clear();
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'isUser': isUser,
      'message': message,
      'date': date.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      isUser: map['isUser'],
      message: map['message'],
      date: DateTime.parse(map['date']),
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// import 'navbar.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _userInput = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   bool _isLoading = false;
//   bool _isListening = false;

//   static const apiKey = "AIzaSyA0p26b2muJvm3mEkY9wPra6JvHZbzw-cY";
//   final model = GenerativeModel(model: 'models/gemini-1.5-pro', apiKey: apiKey);

//   final List<Message> _messages = [];

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (result) {
//         setState(() {
//           _userInput.text = result.recognizedWords;
//         });
//       });
//     }
//   }

//   void _stopListening() {
//     setState(() => _isListening = false);
//     _speech.stop();
//   }

//   Future<void> _exportChat() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/neura_chat.txt';
//     final file = File(path);

//     final content = _messages
//         .map((m) =>
//             '${m.isUser ? "You" : "AI"} [${DateFormat('MMM d, hh:mm a').format(m.date)}]: ${m.message}')
//         .join('\n\n');

//     await file.writeAsString(content);
//     Share.shareXFiles([XFile(path)], text: 'Neura Chat Export');
//   }

//   Future<void> sendMessage() async {
//     final message = _userInput.text.trim();
//     if (message.isEmpty) return;

//     setState(() {
//       _isLoading = true;
//       _messages
//           .add(Message(isUser: true, message: message, date: DateTime.now()));
//     });
//     _scrollToBottom();

//     try {
//       final content = [Content.text(message)];
//       final response = await model.generateContent(content);

//       setState(() {
//         _isLoading = false;
//         _messages.add(Message(
//           isUser: false,
//           message: response.text ?? "No response received",
//           date: DateTime.now(),
//         ));
//       });
//       _scrollToBottom();
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error: Unable to generate response")),
//       );
//       _messages.add(Message(
//         isUser: false,
//         message: "Error: Unable to generate response.",
//         date: DateTime.now(),
//       ));
//       _scrollToBottom();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        bottomNavigationBar: BottomNavBar(
//         currentIndex: 3,
//         onTap: (index) {
//           // Handle bottom nav tap if needed
//         },
//       ),
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         title: const Text(
//           'Neura',
//           style: TextStyle(
//             fontFamily: 'Onest',
//             fontSize: 24,
//             color: Colors.black54,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_forever, color: Colors.black54),
//             onPressed: () => setState(() => _messages.clear()),
//           ),
//           IconButton(
//             icon: const Icon(Icons.share_outlined, color: Colors.black54),
//             onPressed: _messages.isEmpty ? null : _exportChat,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(20),
//               itemCount: _messages.length + (_isLoading ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (_isLoading && index == _messages.length) {
//                   return const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       child: Text("Typing...", style: TextStyle(fontSize: 19)),
//                     ),
//                   );
//                 }

//                 final msg = _messages[index];
//                 final formattedDate = DateFormat('hh:mm a').format(msg.date);

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Align(
//                     alignment: msg.isUser
//                         ? Alignment.centerRight
//                         : Alignment.centerLeft,
//                     child: Column(
//                       crossAxisAlignment: msg.isUser
//                           ? CrossAxisAlignment.end
//                           : CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: msg.isUser
//                                 ? const Color(0xFFEAE6E3)
//                                 : Colors.grey[100],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: msg.isUser
//                               ? Text(
//                                   msg.message,
//                                   style: const TextStyle(
//                                       fontSize: 19, color: Colors.black),
//                                 )
//                               : MarkdownBody(
//                                   data: msg.message,
//                                   styleSheet: MarkdownStyleSheet(
//                                     p: const TextStyle(
//                                         fontSize: 19, color: Colors.black),
//                                   ),
//                                 ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(formattedDate,
//                             style: const TextStyle(
//                                 fontSize: 12, color: Colors.grey)),
//                         if (!msg.isUser)
//                           Row(
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.thumb_up_alt_outlined,
//                                     size: 18),
//                                 onPressed: () {},
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.thumb_down_alt_outlined,
//                                     size: 18),
//                                 onPressed: () {},
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (_isLoading) const LinearProgressIndicator(),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
//                       color: Colors.redAccent),
//                   onPressed: _isListening ? _stopListening : _startListening,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _userInput,
//                     minLines: 1,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: 'Send a message',
//                       hintStyle:
//                           const TextStyle(fontSize: 19, color: Colors.black54),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send_sharp,
//                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
//                   onPressed: _isLoading
//                       ? null
//                       : () {
//                           if (_userInput.text.trim().isNotEmpty) {
//                             sendMessage();
//                             _userInput.clear();
//                           }
//                         },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Message {
//   final bool isUser;
//   final String message;
//   final DateTime date;

//   Message({required this.isUser, required this.message, required this.date});
// }


// // import 'package:flutter/material.dart';
// // import 'package:google_generative_ai/google_generative_ai.dart';



// // class ChatScreen extends StatefulWidget {
// //   const ChatScreen({super.key});

// //   @override
// //   _ChatScreenState createState() => _ChatScreenState();
// // }

// // class _ChatScreenState extends State<ChatScreen> {
// //   TextEditingController _userInput = TextEditingController();
// //   bool _isLoading = false;

// //   static const apiKey = "AIzaSyA0p26b2muJvm3mEkY9wPra6JvHZbzw-cY";
// //   final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

// //   final List<Message> _messages = [];

// //   Future<void> sendMessage() async {
// //     final message = _userInput.text;
// //     if (message.isEmpty) return;

// //     setState(() {
// //       _isLoading = true;
// //       _messages
// //           .add(Message(isUser: true, message: message, date: DateTime.now()));
// //     });

// //     final content = [Content.text(message)];
// //     final response = await model.generateContent(content);

// //     setState(() {
// //       _isLoading = false;
// //       _messages.add(Message(
// //           isUser: false, message: response.text ?? "", date: DateTime.now()));
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
// //           onPressed: () {
// //             Navigator.pop(context); // Modify this to navigate back as needed
// //           },
// //         ),
// //         centerTitle: true,
// //         title: const Text(
// //           'Neura',
// //           style: TextStyle(
// //             fontFamily: 'Onest',
// //             fontSize: 24,
// //             color: Colors.black54,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: ListView.builder(
// //               padding: const EdgeInsets.all(20),
// //               itemCount: _messages.length,
// //               itemBuilder: (context, index) {
// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 10),
// //                   child: Align(
// //                     alignment: _messages[index].isUser
// //                         ? Alignment.centerRight
// //                         : Alignment.centerLeft,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(10),
// //                       decoration: BoxDecoration(
// //                         color: _messages[index].isUser
// //                             ? const Color(0xFFEAE6E3)
// //                             : Colors.grey[100],
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       child: Text(
// //                         _messages[index].message,
// //                         style:
// //                             const TextStyle(fontSize: 19, color: Colors.black),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           if (_isLoading) const LinearProgressIndicator(),
// //           Padding(
// //             padding: const EdgeInsets.all(20.0),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _userInput,
// //                     minLines: 1,
// //                     maxLines: 3,
// //                     decoration: InputDecoration(
// //                       hintText: 'Send a message',
// //                       hintStyle:
// //                           const TextStyle(fontSize: 19, color: Colors.black54),
// //                       filled: true,
// //                       fillColor: Colors.grey[200],
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.send_sharp,
// //                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
// //                   onPressed: _isLoading
// //                       ? null
// //                       : () {
// //                           if (_userInput.text.isNotEmpty) {
// //                             sendMessage();
// //                             _userInput.clear();
// //                           }
// //                         },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class Message {
// //   final bool isUser;
// //   final String message;
// //   final DateTime date;

// //   Message({required this.isUser, required this.message, required this.date});
// // }

// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'dart:math';

// // // import 'package:flutter/material.dart';
// // // import 'package:googleapis_auth/auth_io.dart';

// // // import 'chatbot_intro.dart';
// // // import 'chatbot_voice_interaction.dart';

// // // void main() {
// // //   runApp(const MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return const MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       home: ChatScreen(),
// // //     );
// // //   }
// // // }

// // // class ChatScreen extends StatefulWidget {
// // //   const ChatScreen({super.key});

// // //   @override
// // //   _ChatScreenState createState() => _ChatScreenState();
// // // }

// // // class _ChatScreenState extends State<ChatScreen> {
// // //   final TextEditingController _controller = TextEditingController();
// // //   final List<String> _messages = [];
// // //   bool _isLoading = false;

// // //   // Generate unique session ID
// // //   final String _sessionId = generateSessionId();

// // //   static String generateSessionId() {
// // //     return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
// // //   }

// // //   // Load Service Account Credentials from a JSON file
// // //   Future<AutoRefreshingAuthClient> getAuthClient() async {
// // //     final credentials = ServiceAccountCredentials.fromJson(
// // //       File('/Users/Renad/Desktop/College/Graduation project/mindmed/assets/credentials/mindmed-443019-9c10726937be.json')
// // //           .readAsStringSync(),
// // //     );

// // //     final scopes = [
// // //       'https://www.googleapis.com/auth/dialogflow'
// // //     ]; // Dialogflow API scope
// // //     return await clientViaServiceAccount(credentials, scopes);
// // //   }

// // //   // Send message to Dialogflow API and get a response
// // //   Future<void> sendMessage(String userMessage) async {
// // //     setState(() {
// // //       _isLoading = true;
// // //       _messages.add('You: $userMessage');
// // //     });

// // //     try {
// // //       final authClient = await getAuthClient(); // Authenticate with OAuth 2.0
// // //       final String requestUrl =
// // //           'https://dialogflow.googleapis.com/v2/projects/mindmed-443019/agent/sessions/$_sessionId:detectIntent';

// // //       print('Request URL: $requestUrl'); // Log the request URL for debugging

// // //       final response = await authClient.post(
// // //         Uri.parse(requestUrl),
// // //         headers: {'Content-Type': 'application/json; charset=utf-8'},
// // //         body: jsonEncode({
// // //           'queryInput': {
// // //             'text': {
// // //               'text': userMessage,
// // //               'languageCode': 'en', // Required language code
// // //             },
// // //           },
// // //         }),
// // //       );

// // //       if (response.statusCode == 200) {
// // //         final responseData = jsonDecode(response.body);
// // //         final botResponse = responseData['queryResult']['fulfillmentText'] ??
// // //             'No response available';
// // //         setState(() {
// // //           _messages.add('Neura: $botResponse');
// // //         });
// // //       } else if (response.statusCode == 404) {
// // //         setState(() {
// // //           _messages.add(
// // //               'Neura: Agent not found. Please check the project configuration.');
// // //         });
// // //       } else {
// // //         setState(() {
// // //           _messages.add('Neura: Something went wrong. Please try again later.');
// // //         });
// // //         throw Exception(
// // //             'Failed with status code: ${response.statusCode}, body: ${response.body}');
// // //       }

// // //       authClient.close(); // Close the authenticated client
// // //     } catch (e) {
// // //       print('Error occurred: $e');
// // //       setState(() {
// // //         _messages.add('Neura: Sorry, something went wrong. Please try again.');
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
// // //           onPressed: () {
// // //             Navigator.push(
// // //               context,
// // //               MaterialPageRoute(builder: (context) => const ChatbotIntro()),
// // //             );
// // //           },
// // //         ),
// // //         centerTitle: true,
// // //         title: const Text(
// // //           'Neura',
// // //           style: TextStyle(
// // //             fontFamily: 'Onest',
// // //             fontSize: 24,
// // //             color: Colors.black54,
// // //             fontWeight: FontWeight.bold,
// // //           ),
// // //         ),
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           Expanded(
// // //             child: ListView.builder(
// // //               padding: const EdgeInsets.all(20),
// // //               itemCount: _messages.length,
// // //               itemBuilder: (context, index) {
// // //                 return Padding(
// // //                   padding: const EdgeInsets.symmetric(vertical: 10),
// // //                   child: Align(
// // //                     alignment: _messages[index].startsWith('You')
// // //                         ? Alignment.centerRight
// // //                         : Alignment.centerLeft,
// // //                     child: Container(
// // //                       padding: const EdgeInsets.all(10),
// // //                       decoration: BoxDecoration(
// // //                         color: _messages[index].startsWith('You')
// // //                             ? const Color(0xFFEAE6E3)
// // //                             : Colors.grey[100],
// // //                         borderRadius: BorderRadius.circular(10),
// // //                       ),
// // //                       child: Text(
// // //                         _messages[index],
// // //                         style:
// // //                             const TextStyle(fontSize: 19, color: Colors.black),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           if (_isLoading) const LinearProgressIndicator(),
// // //           Padding(
// // //             padding: const EdgeInsets.all(20.0),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: TextField(
// // //                     controller: _controller,
// // //                     minLines: 1,
// // //                     maxLines: 3,
// // //                     decoration: InputDecoration(
// // //                       hintText: 'Send a message',
// // //                       hintStyle:
// // //                           const TextStyle(fontSize: 19, color: Colors.black54),
// // //                       filled: true,
// // //                       fillColor: Colors.grey[200],
// // //                       border: OutlineInputBorder(
// // //                         borderRadius: BorderRadius.circular(10),
// // //                         borderSide: BorderSide.none,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 IconButton(
// // //                   icon: const Icon(Icons.send_sharp,
// // //                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
// // //                   onPressed: _isLoading
// // //                       ? null
// // //                       : () {
// // //                           if (_controller.text.isNotEmpty) {
// // //                             sendMessage(_controller.text);
// // //                             _controller.clear();
// // //                           }
// // //                         },
// // //                 ),
// // //                 IconButton(
// // //                   icon: const Icon(Icons.mic,
// // //                       size: 41, color: Color.fromARGB(255, 220, 195, 175)),
// // //                   onPressed: () {
// // //                     Navigator.push(
// // //                       context,
// // //                       MaterialPageRoute(
// // //                           builder: (context) => const VoiceInteractionScreen()),
// // //                     );
// // //                   },
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:googleapis_auth/auth_io.dart';
// // // import 'dart:io';
// // // import 'package:http/http.dart' as http;
// // // import 'dart:convert';
// // // import 'dart:math';

// // // import 'chatbot_voice_interaction.dart';
// // // import 'chatbot_intro.dart';

// // // void main() {
// // //   runApp(MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       home: ChatScreen(),
// // //     );
// // //   }
// // // }

// // // class ChatScreen extends StatefulWidget {
// // //   @override
// // //   _ChatScreenState createState() => _ChatScreenState();
// // // }

// // // class _ChatScreenState extends State<ChatScreen> {
// // //   final TextEditingController _controller = TextEditingController();
// // //   final List<String> _messages = [];
// // //   bool _isLoading = false;

// // //   // Generate unique session ID
// // //   final String _sessionId = generateSessionId();

// // //   static String generateSessionId() {
// // //     return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
// // //   }

// // //   // Load Service Account Credentials from a JSON file
// // //   Future<AutoRefreshingAuthClient> getAuthClient() async {
// // //     final credentials = ServiceAccountCredentials.fromJson(
// // //       File('/Users/shahdayman/Documents/Projects/Flutter Projects/mindmed/assets/credentials/mindmed-443019-9c10726937be.json').readAsStringSync(),
// // //     );

// // //     final _scopes = [
// // //       'https://www.googleapis.com/auth/dialogflow'
// // //     ]; // Dialogflow API scope
// // //     return await clientViaServiceAccount(credentials, _scopes);
// // //   }

// // //   // Send message to Dialogflow API and get a response
// // //   Future<void> sendMessage(String userMessage) async {
// // //     setState(() {
// // //       _isLoading = true;
// // //       _messages.add('You: $userMessage');
// // //     });

// // //     try {
// // //       final authClient = await getAuthClient(); // Authenticate with OAuth 2.0
// // //       final String requestUrl =
// // //           'https://dialogflow.googleapis.com/v2/projects/mindmed-443019/agent/sessions/$_sessionId:detectIntent';

// // //       print('Request URL: $requestUrl');  // Log the request URL for debugging

// // //       final response = await authClient.post(
// // //         Uri.parse(requestUrl),
// // //         headers: {'Content-Type': 'application/json; charset=utf-8'},
// // //         body: jsonEncode({
// // //           'queryInput': {
// // //             'text': {
// // //               'text': userMessage,
// // //               'languageCode': 'en', // Required language code
// // //             },
// // //           },
// // //         }),
// // //       );

// // //       if (response.statusCode == 200) {
// // //         final responseData = jsonDecode(response.body);
// // //         final botResponse = responseData['queryResult']['fulfillmentText'] ??
// // //             'No response available';
// // //         setState(() {
// // //           _messages.add('Neura: $botResponse');
// // //         });
// // //       } else if (response.statusCode == 404) {
// // //         setState(() {
// // //           _messages.add('Neura: Agent not found. Please check the project configuration.');
// // //         });
// // //       } else {
// // //         setState(() {
// // //           _messages.add('Neura: Something went wrong. Please try again later.');
// // //         });
// // //         throw Exception('Failed with status code: ${response.statusCode}, body: ${response.body}');
// // //       }

// // //       authClient.close(); // Close the authenticated client
// // //     } catch (e) {
// // //       print('Error occurred: $e');
// // //       setState(() {
// // //         _messages.add('Neura: Sorry, something went wrong. Please try again.');
// // //       });
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
// // //           onPressed: () {
// // //             Navigator.push(
// // //               context,
// // //               MaterialPageRoute(builder: (context) => ChatbotIntro()),
// // //             );
// // //           },
// // //         ),
// // //         centerTitle: true,
// // //         title: Text(
// // //           'Neura',
// // //           style: TextStyle(
// // //             fontFamily: 'Onest',
// // //             fontSize: 24,
// // //             color: Colors.black54,
// // //             fontWeight: FontWeight.bold,
// // //           ),
// // //         ),
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           Expanded(
// // //             child: ListView.builder(
// // //               padding: EdgeInsets.all(20),
// // //               itemCount: _messages.length,
// // //               itemBuilder: (context, index) {
// // //                 return Padding(
// // //                   padding: const EdgeInsets.symmetric(vertical: 10),
// // //                   child: Align(
// // //                     alignment: _messages[index].startsWith('You')
// // //                         ? Alignment.centerRight
// // //                         : Alignment.centerLeft,
// // //                     child: Container(
// // //                       padding: EdgeInsets.all(10),
// // //                       decoration: BoxDecoration(
// // //                         color: _messages[index].startsWith('You')
// // //                             ? Color(0xFFEAE6E3)
// // //                             : Colors.grey[100],
// // //                         borderRadius: BorderRadius.circular(10),
// // //                       ),
// // //                       child: Text(
// // //                         _messages[index],
// // //                         style: TextStyle(fontSize: 19, color: Colors.black),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ),
// // //           if (_isLoading) LinearProgressIndicator(),
// // //           Padding(
// // //             padding: const EdgeInsets.all(20.0),
// // //             child: Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: TextField(
// // //                     controller: _controller,
// // //                     minLines: 1,
// // //                     maxLines: 3,
// // //                     decoration: InputDecoration(
// // //                       hintText: 'Send a message',
// // //                       hintStyle: TextStyle(fontSize: 19, color: Colors.black54),
// // //                       filled: true,
// // //                       fillColor: Colors.grey[200],
// // //                       border: OutlineInputBorder(
// // //                         borderRadius: BorderRadius.circular(10),
// // //                         borderSide: BorderSide.none,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 IconButton(
// // //                   icon: Icon(Icons.send_sharp,
// // //                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
// // //                   onPressed: _isLoading
// // //                       ? null
// // //                       : () {
// // //                           if (_controller.text.isNotEmpty) {
// // //                             sendMessage(_controller.text);
// // //                             _controller.clear();
// // //                           }
// // //                         },
// // //                 ),
// // //                 IconButton(
// // //                   icon: Icon(Icons.mic,
// // //                       size: 41, color: Color.fromARGB(255, 220, 195, 175)),
// // //                   onPressed: () {
// // //                     Navigator.push(
// // //                       context,
// // //                       MaterialPageRoute(
// // //                           builder: (context) => VoiceInteractionScreen()),
// // //                     );
// // //                   },
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
 
// // // // import 'package:flutter/material.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'chatbot_voice_interaction.dart';
// // // // import 'chatbot_intro.dart';
// // // // import 'dart:convert';


// // // // void main() {
// // // //   runApp(MyApp());
// // // // }

// // // // class MyApp extends StatelessWidget {
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       debugShowCheckedModeBanner: false,
// // // //       home: ChatScreen(),
// // // //     );
// // // //   }
// // // // }

// // // // class ChatScreen extends StatefulWidget {
// // // //   @override
// // // //   _ChatScreenState createState() => _ChatScreenState();
// // // // }

// // // // class _ChatScreenState extends State<ChatScreen> {
// // // //   TextEditingController _controller = TextEditingController();
// // // //   List<String> _messages = []; // Stores the chat messages
// // // //   bool _isLoading = false; // Handles loading state for API calls

// // // //   // Your Gemini API details (replace with your actual values)
// // // //   final String _geminiApiUrl =
// // // //       'https://language.googleapis.com/v1/projects/mindmed-443019/locations/global/agents/唠嗑 (Laokua)/sessions/<YOUR_SESSION_ID>/contexts:__session_context';
// // // //   final String _geminiApiKey = 'AIzaSyA0p26b2muJvm3mEkY9wPra6JvHZbzw-cY';

// // // //   // Connect to Gemini API and fetch chatbot response
// // // //   Future<String> sendMessage(String userMessage) async {
// // // //     setState(() {
// // // //       _isLoading = true;
// // // //       _messages.add('You: $userMessage'); // Add user message to chat
// // // //     });

// // // //     try {
// // // //       final response = await http.post(
// // // //         Uri.parse(_geminiApiUrl),
// // // //         headers: {
// // // //           'Authorization': 'Bearer $_geminiApiKey',
// // // //           'Content-Type': 'application/json; charset=utf-8',
// // // //         },
// // // //         body: jsonEncode({
// // // //           'queryInput': {
// // // //             'text': userMessage,
// // // //           },
// // // //         }),
// // // //       );

// // // //       if (response.statusCode == 200) {
// // // //         final responseData = jsonDecode(response.body);
// // // //         final botResponse = responseData['detectIntentResponse']['queryResult']
// // // //             ['fulfillmentText'];
// // // //         setState(() {
// // // //           _messages.add('Neura: $botResponse'); // Add bot response to chat
// // // //         });
// // // //         return botResponse;
// // // //       } else {
// // // //         throw Exception(
// // // //             'API request failed with status: ${response.statusCode}');
// // // //       }
// // // //     } catch (e) {
// // // //       setState(() {
// // // //         _messages.add('Neura: Sorry, an error occurred: $e'); // Error handling
// // // //       });
// // // //       throw e; // Re-throw for potential logging or UI updates
// // // //     } finally {
// // // //       setState(() {
// // // //         _isLoading = false;
// // // //       });
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.white,
// // // //       appBar: AppBar(
// // // //         backgroundColor: Colors.white,
// // // //         elevation: 0,
// // // //         leading: IconButton(
// // // //           icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
// // // //           onPressed: () {
// // // //             Navigator.push(
// // // //               context,
// // // //               MaterialPageRoute(builder: (context) => ChatbotIntro()),
// // // //             );
// // // //           },
// // // //         ),
// // // //         centerTitle: true,
// // // //         title: Text(
// // // //           'Neura',
// // // //           style: TextStyle(
// // // //             fontFamily: 'Onest',
// // // //             fontSize: 24,
// // // //             color: Colors.black54,
// // // //             fontWeight: FontWeight.bold,
// // // //           ),
// // // //         ),
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           Expanded(
// // // //             child: ListView.builder(
// // // //               padding: EdgeInsets.all(20),
// // // //               itemCount: _messages.length,
// // // //               itemBuilder: (context, index) {
// // // //                 return Padding(
// // // //                   padding: const EdgeInsets.symmetric(vertical: 10),
// // // //                   child: Align(
// // // //                     alignment: _messages[index].startsWith('You')
// // // //                         ? Alignment.centerRight
// // // //                         : Alignment.centerLeft,
// // // //                     child: Container(
// // // //                       padding: EdgeInsets.all(10),
// // // //                       decoration: BoxDecoration(
// // // //                         color: _messages[index].startsWith('You')
// // // //                             ? Color(0xFFEAE6E3)
// // // //                             : Colors.grey[100],
// // // //                         borderRadius: BorderRadius.circular(10),
// // // //                       ),
// // // //                       child: Text(
// // // //                         _messages[index],
// // // //                         style: TextStyle(fontSize: 19, color: Colors.black),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 );
// // // //               },
// // // //             ),
// // // //           ),
// // // //           if (_isLoading) LinearProgressIndicator(),
// // // //           // Input Bar
// // // //           Padding(
// // // //             padding: const EdgeInsets.all(20.0),
// // // //             child: Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: TextField(
// // // //                     controller: _controller,
// // // //                     decoration: InputDecoration(
// // // //                       hintText: 'Send a message',
// // // //                       hintStyle: TextStyle(fontSize: 19, color: Colors.black54),
// // // //                       filled: true,
// // // //                       fillColor: Colors.grey[200],
// // // //                       border: OutlineInputBorder(
// // // //                         borderRadius: BorderRadius.circular(10),
// // // //                         borderSide: BorderSide.none,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 IconButton(
// // // //                   icon: Icon(Icons.send_sharp,
// // // //                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
// // // //                   onPressed: () {
// // // //                     if (_controller.text.isNotEmpty) {
// // // //                       sendMessage(_controller.text);
// // // //                       _controller.clear();
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //                 IconButton(
// // // //                   icon: Icon(Icons.mic,
// // // //                       size: 41, color: Color.fromARGB(255, 220, 195, 175)),
// // // //                   onPressed: () {
// // // //                     Navigator.push(
// // // //                       context,
// // // //                       MaterialPageRoute(
// // // //                           builder: (context) => VoiceInteractionScreen()),
// // // //                     );
// // // //                   },
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // // Placeholder for Gemini API integration (using http package)
// // // // // Future<String> fetchChatResponse(String userInput) async {
// // // //   // Use the http package for API requests
// // // //   // ... (implementation moved to sendMessage)
// // // // //}

// // // // // import 'package:flutter/material.dart';
// // // // // import 'chatbot_voice_interaction.dart';
// // // // // import 'chatbot_intro.dart';

// // // // // void main() {
// // // // //   runApp(MyApp());
// // // // // }

// // // // // class MyApp extends StatelessWidget {
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return MaterialApp(
// // // // //       debugShowCheckedModeBanner: false,
// // // // //       home: ChatScreen(),
// // // // //     );
// // // // //   }
// // // // // }
// // // // // class ChatScreen extends StatefulWidget {
// // // // //   @override
// // // // //   _ChatScreenState createState() => _ChatScreenState();
// // // // // }

// // // // // class _ChatScreenState extends State<ChatScreen> {
// // // // //   TextEditingController _controller = TextEditingController();
// // // // //   List<String> _messages = []; // Stores the chat messages
// // // // //   bool _isLoading = false; // Handles loading state for API calls

// // // // //   // Connect to API and fetch chatbot response
// // // // //   Future<void> sendMessage(String userMessage) async {
// // // // //     setState(() {
// // // // //       _isLoading = true;
// // // // //       _messages.add('You: $userMessage'); // Add user message to chat
// // // // //     });

// // // // //     try {
// // // // //       final response = await fetchChatResponse(userMessage); // Call API
// // // // //       setState(() {
// // // // //         _messages.add('Neura: $response'); // Add bot response to chat
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() {
// // // // //         _messages.add('Neura: Sorry, an error occurred.'); // Error handling
// // // // //       });
// // // // //     } finally {
// // // // //       setState(() {
// // // // //         _isLoading = false;
// // // // //       });
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.white,
// // // // //       appBar: AppBar(
// // // // //         backgroundColor: Colors.white,
// // // // //         elevation: 0,
// // // // //         leading: IconButton(
// // // // //           icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
// // // // //           onPressed: () {
// // // // //             Navigator.push(
// // // // //               context,
// // // // //               MaterialPageRoute(builder: (context) => ChatbotIntro()),
// // // // //             );
// // // // //           },
// // // // //         ),
// // // // //         centerTitle: true,
// // // // //         title: Text(
// // // // //           'Neura',
// // // // //           style: TextStyle(
// // // // //             fontFamily: 'Onest',
// // // // //             fontSize: 24,
// // // // //             color: Colors.black54,
// // // // //             fontWeight: FontWeight.bold,
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //       body: Column(
// // // // //         children: [
// // // // //           Expanded(
// // // // //             child: ListView.builder(
// // // // //               padding: EdgeInsets.all(20),
// // // // //               itemCount: _messages.length,
// // // // //               itemBuilder: (context, index) {
// // // // //                 return Padding(
// // // // //                   padding: const EdgeInsets.symmetric(vertical: 10),
// // // // //                   child: Align(
// // // // //                     alignment: _messages[index].startsWith('You')
// // // // //                         ? Alignment.centerRight
// // // // //                         : Alignment.centerLeft,
// // // // //                     child: Container(
// // // // //                       padding: EdgeInsets.all(10),
// // // // //                       decoration: BoxDecoration(
// // // // //                         color: _messages[index].startsWith('You')
// // // // //                             ? Color(0xFFEAE6E3)
// // // // //                             : Colors.grey[100],
// // // // //                         borderRadius: BorderRadius.circular(10),
// // // // //                       ),
// // // // //                       child: Text(
// // // // //                         _messages[index],
// // // // //                         style: TextStyle(fontSize: 19, color: Colors.black),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 );
// // // // //               },
// // // // //             ),
// // // // //           ),
// // // // //           if (_isLoading) LinearProgressIndicator(),
// // // // //           // Input Bar
// // // // //           Padding(
// // // // //             padding: const EdgeInsets.all(20.0),
// // // // //             child: Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: TextField(
                    
// // // // //                     controller: _controller,
// // // // //                     decoration: InputDecoration(
                      
// // // // //                       hintText: 'Send a message',
// // // // //                       hintStyle: TextStyle(fontSize: 19,color: Colors.black54),
// // // // //                       filled: true,
// // // // //                       fillColor: Colors.grey[200],
// // // // //                       border: OutlineInputBorder(
// // // // //                         borderRadius: BorderRadius.circular(10),
// // // // //                         borderSide: BorderSide.none,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 IconButton(
// // // // //                   icon: Icon(Icons.send_sharp,
// // // // //                       size: 40, color: Color.fromARGB(255, 220, 195, 175)),
// // // // //                   onPressed: () {
// // // // //                     if (_controller.text.isNotEmpty) {
// // // // //                       sendMessage(_controller.text);
// // // // //                       _controller.clear();
// // // // //                     }
// // // // //                   },
// // // // //                 ),
// // // // //                 IconButton(
// // // // //                   icon: Icon(Icons.mic,size: 41,
// // // // //                       color: Color.fromARGB(255, 220, 195, 175)),
// // // // //                   onPressed: () {
// // // // //                 Navigator.push(
// // // // //                   context,
// // // // //                   MaterialPageRoute(builder: (context) => VoiceInteractionScreen()),
// // // // //                 );
// // // // //               },
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // Placeholder for Gemini API integration
// // // // // Future<String> fetchChatResponse(String userInput) async {
// // // // //   // Replace with your API integration logic
// // // // //   // Example of API call (pseudo-code):
// // // // //   // final response = await http.post(
// // // // //   //   Uri.parse('https://gemini-api.example.com/chat'),
// // // // //   //   headers: {'Authorization': 'Bearer YOUR_TOKEN'},
// // // // //   //   body: {'message': userInput},
// // // // //   // );
// // // // //   // return response.data['reply'];

// // // // //   // Mocked response for testing
// // // // //   return Future.delayed(
// // // // //     Duration(seconds: 1),
// // // // //     () => "This is a Gemini API response to '$userInput'.",
// // // // //   );
// // // // // }
