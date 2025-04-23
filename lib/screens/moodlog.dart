
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_dashboard.dart';


class MoodLoggingPage extends StatefulWidget {
  const MoodLoggingPage({super.key});

  @override
  State<MoodLoggingPage> createState() => _MoodLoggingPageState();
}


class _MoodLoggingPageState extends State<MoodLoggingPage> {
  double _moodValue = 0.5;

  String getMoodFromValue(double value) {
    if (value < 0.33) return "Unpleasant";
    if (value < 0.66) return "Neutral";
    return "Pleasant";
  }

  Future<void> logMood() async {
    final String mood = getMoodFromValue(_moodValue);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first.")),
      );
      return;
    }

    final String baseUrl =
        // Platform.isAndroid ? 'http://10.0.2.2:5002' : 'http://localhost:5002';
                Platform.isAndroid ? 'http://10.0.2.2:5002' : 'http://192.168.1.18:5002';

    final Uri url = Uri.parse('$baseUrl/api/mood/log-mood');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mood': mood}),
      );

      final resData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mood logged: $mood ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resData['message'] ?? "Failed to log mood")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
       Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
      IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),                  const SizedBox(width: 38.0),
                    const Text(
                      'Mood Logging',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 35,
                        fontFamily: 'Gayathri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                const Center(
                  child: Text(
                    'How do you rate your mood over the day?',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Gayathri-Regular',
                      fontWeight: FontWeight.w700,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MoodLabel(
                              label: 'Pleasant',
                              imagePath: 'assets/images/moodlog1.png',
                              width: 90,
                              height: 90,
                            ),
                            SizedBox(height: 60),
                            MoodLabel(
                              label: 'Neutral',
                              imagePath: 'assets/images/moodlog2.png',
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 60),
                            MoodLabel(
                              label: 'Unpleasant',
                              imagePath: 'assets/images/moodlog3.png',
                              width: 110,
                              height: 110,
                            ),
                          ],
                        ),
                        RotatedBox(
                          quarterTurns: -1,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 12,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 15.0),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 90.0),
                              thumbColor: Colors.orange,
                              activeTrackColor: Colors.orange,
                              inactiveTrackColor: Colors.grey[300],
                            ),
                            child: Slider(
                              value: _moodValue,
                              onChanged: (value) {
                                setState(() {
                                  _moodValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: logMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      "Log My Mood",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                // const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    
  }
}

class MoodLabel extends StatelessWidget {
  final String label;
  final String imagePath;
  final double width;
  final double height;

  const MoodLabel({
    super.key,
    required this.label,
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.brown,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Image.asset(imagePath, width: width, height: height),
      ],
    );
  }
}// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io'; // 👈 Required to detect Android/iOS

// class MoodLoggerApp extends StatelessWidget {
//   const MoodLoggerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MoodLoggingPage(),
//     );
//   }
// }

// class MoodLoggingPage extends StatefulWidget {
//   const MoodLoggingPage({super.key});

//   @override
//   _MoodLoggingPageState createState() => _MoodLoggingPageState();
// }

// class _MoodLoggingPageState extends State<MoodLoggingPage> {
//   double _moodValue = 0.5;

//   /// Converts the slider value to mood label
//   String getMoodFromValue(double value) {
//     if (value < 0.33) return "Unpleasant";
//     if (value < 0.66) return "Neutral";
//     return "Pleasant";
//   }

//   /// Sends POST request to backend to log the mood
//   Future<void> logMood() async {
//     final String mood = getMoodFromValue(_moodValue);
//     final String token = 'YOUR_JWT_TOKEN_HERE'; // Replace with stored token

//     // 👇 Correct host based on platform
//     final String baseUrl =
//         Platform.isAndroid ? 'http://10.0.2.2:5002' : 'http://localhost:5002';

//     final Uri url = Uri.parse('$baseUrl/api/mood/log-mood');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({'mood': mood}),
//       );

//       final result = json.decode(response.body);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Mood logged: $mood ✅")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(result['message'] ?? "Failed to log mood")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Network error. Check your connection.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Icon(Icons.arrow_back, color: Colors.brown),
//                   SizedBox(width: 8),
//                   Text(
//                     'Mood Logging',
//                     style: TextStyle(
//                       color: Colors.brown,
//                       fontSize: 30,
//                       fontFamily: 'Gayathri',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 70),
//               const Center(
//                 child: Text(
//                   'How do you rate your mood over the day?',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontFamily: 'Gayathri-Regular',
//                     fontWeight: FontWeight.w700,
//                     color: Colors.brown,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 50),
//               Expanded(
//                 child: Center(
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       const Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           MoodLabel(
//                               label: 'Pleasant',
//                               imagePath: 'assets/images/moodlog2.png',
//                               width: 100,
//                               height: 100),
//                           SizedBox(height: 60),
//                           MoodLabel(
//                               label: 'Neutral',
//                               imagePath: 'assets/images/moodlog2.png',
//                               width: 100,
//                               height: 100),
//                           SizedBox(height: 60),
//                           MoodLabel(
//                               label: 'Unpleasant',
//                               imagePath: 'assets/images/moodlog3.png',
//                               width: 110,
//                               height: 110),
//                         ],
//                       ),
//                       RotatedBox(
//                         quarterTurns: -1,
//                         child: SliderTheme(
//                           data: SliderTheme.of(context).copyWith(
//                             trackHeight: 12,
//                             thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 15.0),
//                             overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 90.0),
//                             thumbColor: Colors.orange,
//                             activeTrackColor: Colors.orange,
//                             inactiveTrackColor: Colors.grey[300],
//                           ),
//                           child: Slider(
//                             value: _moodValue,
//                             onChanged: (value) {
//                               setState(() {
//                                 _moodValue = value;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: logMood,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.brown,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 15),
//                   ),
//                   child: const Text(
//                     "Log My Mood",
//                     style: TextStyle(fontSize: 20, color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MoodLabel extends StatelessWidget {
//   final String label;
//   final String imagePath;
//   final double width;
//   final double height;

//   const MoodLabel({
//     super.key,
//     required this.label,
//     required this.imagePath,
//     required this.width,
//     required this.height,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.brown,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Image.asset(imagePath, width: width, height: height),
//       ],
//     );
//   }
// }

// // import 'package:flutter/material.dart';

// // class MoodLoggerApp extends StatelessWidget {
// //   const MoodLoggerApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: MoodLoggingPage(),
// //     );
// //   }
// // }

// // class MoodLoggingPage extends StatefulWidget {
// //   const MoodLoggingPage({super.key});

// //   @override
// //   _MoodLoggingPageState createState() => _MoodLoggingPageState();
// // }

// // class _MoodLoggingPageState extends State<MoodLoggingPage> {
// //   double _moodValue = 0.5;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(25.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Row(
// //                 children: [
// //                   Icon(Icons.arrow_back, color: Colors.brown),
// //                   SizedBox(width: 8),
// //                   Text('Mood Logging',
// //                       style: TextStyle(
// //                           color: Colors.brown,
// //                           fontSize: 30,
// //                           fontFamily: 'Gayathri',
// //                           fontWeight: FontWeight.bold)),
// //                 ],
// //               ),
// //               const SizedBox(height: 70),
// //               const Center(
// //                 child: Text(
// //                   'How do you rate your mood over the day?',
// //                   style: TextStyle(
// //                       fontSize: 22,
// //                       fontFamily: 'Gayathri-Regular',
// //                       fontWeight: FontWeight.w700,
// //                       color: Colors.brown),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //               const SizedBox(height: 50),
// //               Expanded(
// //                 child: Center(
// //                   child: Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       const Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           MoodLabel(
// //                               label: 'Pleasant',
// //                               imagePath: 'assets/images/moodlog2.png',
// //                               width: 100,
// //                               height: 100),
// //                           SizedBox(height: 60),
// //                           MoodLabel(
// //                               label: 'Neutral',
// //                               imagePath: 'assets/images/moodlog2.png',
// //                               width: 100,
// //                               height: 100),
// //                           SizedBox(height: 60),
// //                           MoodLabel(
// //                               label: 'Unpleasant',
// //                               imagePath: 'assets/images/moodlog3.png',
// //                               width: 110,
// //                               height: 110),
// //                         ],
// //                       ),
// //                       RotatedBox(
// //                         quarterTurns: -1,
// //                         child: SliderTheme(
// //                           data: SliderTheme.of(context).copyWith(
// //                             trackHeight: 12,
// //                             thumbShape: const RoundSliderThumbShape(
// //                                 enabledThumbRadius: 15.0),
// //                             overlayShape: const RoundSliderOverlayShape(
// //                                 overlayRadius: 90.0),
// //                             thumbColor: Colors.orange,
// //                             activeTrackColor: Colors.orange,
// //                             inactiveTrackColor: Colors.grey[300],
// //                           ),
// //                           child: Slider(
// //                             value: _moodValue,
// //                             onChanged: (value) {
// //                               setState(() {
// //                                 _moodValue = value;
// //                               });
// //                             },
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class MoodLabel extends StatelessWidget {
// //   final String label;
// //   final String imagePath;
// //   final double width;
// //   final double height;

// //   const MoodLabel({
// //     super.key,
// //     required this.label,
// //     required this.imagePath,
// //     required this.width,
// //     required this.height,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             color: Colors.brown,
// //             fontSize: 22,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         Image.asset(imagePath, width: width, height: height),
// //       ],
// //     );
// //   }
// // }
