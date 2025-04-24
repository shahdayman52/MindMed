
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mindmed/config.dart';
import 'resetPassword.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  const OTPVerificationPage({super.key, required this.email});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String errorMsg = '';

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    final response = await http.post(
      Uri.parse('http://$BaseUrl1/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'otp': otpController.text}),
    );

    final resData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetScreen(email: widget.email),
        ),
      );
    } else {
      setState(() {
        errorMsg = resData['message'] ?? 'OTP verification failed.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/registrationbackground.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 270),
                  const Text(
                    "Enter the 6-digit code sent to your email",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6C635D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (errorMsg.isNotEmpty)
                    Text(
                      errorMsg,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 30),
                  OutlinedButton(
                    onPressed: isLoading ? null : verifyOtp,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC3B5AC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.brown)
                        : const Text(
                            "Verify OTP",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 156, 93, 93),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'resetPassword.dart';
// import 'dart:convert';

// // import 'reset_password_screen.dart'; // Update this import to match your filename

// class OTPVerificationPage extends StatefulWidget {
//   final String email;
//   const OTPVerificationPage({super.key, required this.email});

//   @override
//   State<OTPVerificationPage> createState() => _OTPVerificationPageState();
// }

// class _OTPVerificationPageState extends State<OTPVerificationPage> {
//   final TextEditingController otpController = TextEditingController();
//   bool isLoading = false;
//   String errorMsg = '';

//   Future<void> verifyOtp() async {
//     setState(() {
//       isLoading = true;
//       errorMsg = '';
//     });

//     final response = await http.post(
//       // Uri.parse('http://localhost:5002/api/auth/send-otp'),
//             Uri.parse('http://192.168.1.18:5002/api/auth/send-otp'),

//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': widget.email, 'otp': otpController.text}),
//     );

//     final resData = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PasswordResetScreen(email: widget.email),
//         ),
//       );
//     } else {
//       setState(() {
//         errorMsg = resData['message'] ?? 'OTP verification failed.';
//       });
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
//         child: Column(
//           children: [
//             const Text(
//               'Enter the 6-digit code sent to your email',
//               style: TextStyle(fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: const InputDecoration(
//                 labelText: 'OTP Code',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             if (errorMsg.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10),
//                 child: Text(
//                   errorMsg,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: isLoading ? null : verifyOtp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFC3B5AC),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Verify OTP',
//                       style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
