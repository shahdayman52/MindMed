import 'package:flutter/material.dart';
import 'package:mindmed/services/notification_service.dart';
import 'intro.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    scheduleDailyNotifications();

    // Navigate to the registration page after 2 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Intro()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 182, 168, 159), // Light brown background
      body: Stack(
        children: [
          // MindMed text at the top-right
          Positioned(
            top: 80, // Adjust vertical position
            right: 20, // Adjust horizontal position
            child: Text(
              'MindMed',
              style: TextStyle(
                fontFamily: 'Onest',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Center content (logo and text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/intro.png', // Replace with your main logo image path
                  width: 400, // Adjust size as needed
                  height: 400,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Find Peace Within',
                  style: TextStyle(
                    fontFamily: 'Gayathri', // Custom font family
                    fontSize: 38, // Font size
                    fontWeight: FontWeight.w400, // Regular weight
                    color: Colors.white, // Font color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'intro.dart';



// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to the registration page after 2 seconds
//     Future.delayed(const Duration(seconds: 5), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Intro()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//      backgroundColor:  Color.fromARGB(255, 182, 168, 159), // Light brown background
//       body: Stack(
//         children: [
//           // MindMed text at the top-right
//           Positioned(
//             top: 80, // Adjust vertical position
//             right: 20, // Adjust horizontal position
//             child: Text(
//               'MindMed',
//               style: TextStyle(
//                 fontFamily: 'Onest',
//                 fontSize: 24,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Center content (logo and text)
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/intro.png', // Replace with your main logo image path
//                   width: 400, // Adjust size as needed
//                   height: 400,
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Find Peace Within',
//                   style: TextStyle(
//                     fontFamily: 'Gayathri', // Custom font family
//                     fontSize: 38, // Font size
//                     fontWeight: FontWeight.w400, // Regular weight
//                     color: Colors.white, // Font color
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
