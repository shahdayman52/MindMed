import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login.dart'; // Import your login page widget

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response = await AuthService.registerUser(name, email, password);

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        //Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        //context,
        //MaterialPageRoute(builder: (context) => ()),
        // );
      } else {
        final errors = jsonDecode(response.body)['errors'];
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.join('\n')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Background Image with Overlay
              Container(
                height: 1000,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/images/registrationbackground.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                          height:
                              350), // Push content below the background image

                      // Name Field with Top Label and Shadow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6C635D),
                            ),
                          ),
                          const SizedBox(height: 5),
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
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name is required.';
                                } else if (value.length < 2) {
                                  return 'Name must be at least 2 characters long.';
                                } else if (value.length > 50) {
                                  return 'Name must not exceed 50 characters.';
                                } else if (!RegExp(r"^[a-zA-Z\s'-]+$")
                                    .hasMatch(value)) {
                                  return 'Name can only contain letters, spaces, hyphens, and apostrophes.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email Field with Top Label and Shadow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6C635D),
                            ),
                          ),
                          const SizedBox(height: 5),
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
                            child: TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required.';
                                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Password Field with Top Label and Shadow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6C635D),
                            ),
                          ),
                          const SizedBox(height: 5),
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
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required.';
                                } else if (value.length < 8) {
                                  return 'Password must be at least 8 characters long.';
                                } else if (value.length > 64) {
                                  return 'Password must not exceed 64 characters.';
                                } else if (!RegExp(
                                        r'(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])')
                                    .hasMatch(value)) {
                                  return 'Password must include uppercase, lowercase, a number, and a special character.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),

                      // Sign-Up Button
                      OutlinedButton(
                        onPressed: () => registerUser(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFC3B5AC)), // Border color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 15),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF82634E), // Button text color
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Redirect
                      GestureDetector(
                        onTap: () {
                          // Navigate to Login Page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF82634E), // Text color
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// // File: lib/screens/registration_screen.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; 
// import 'homepage.dart'; 

// class Register extends StatefulWidget {
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<Register> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   // Placeholder Firebase function for random username generation
//   Future<void> generateRandomUsername() async {
//     setState(() {
//       usernameController.text = "User123"; // Temporary value
//     });
//   }

//   Future<void> registerUser() async {
//     String name = nameController.text;
//     String email = emailController.text;
//     String password = passwordController.text;

//     final Map<String, dynamic> requestBody = {
//       'name': name,
//       'email': email,
//       'password': password,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(
//             'http://localhost:5001/api/auth/register'), // Replace with your backend URL
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}'); // Log the response

// if (response.statusCode == 201) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => HomePage()),
//         );
//       } else {
//         print("Error: ${response.statusCode} - ${response.body}"); // Log error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Registration Unsuccessful: ${response.body}')),
//         );
//       }
//     } catch (e) {
//       print('Error: $e'); // Log any error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 80),
//             // Top Bar with App Name
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(
//                   "MindMed",
//                   style: TextStyle(
//                     fontFamily: 'Onest',
//                     fontSize: 24,
//                     color: Colors.black54,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             // Welcome Text
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Text(
//                 "Welcome!",
//                 style: TextStyle(
//                   fontFamily: 'OpenSans',
//                   fontSize: 38,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             // What do you like to be called? Field
//             Text(
//               "What do you like to be called?",
//               style: TextStyle(
//                   fontFamily: 'Onest', fontSize: 22, color: Colors.black54),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 hintText: '',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             // Username Input Field
//             Text(
//               "Enter username :",
//               style: TextStyle(
//                   fontFamily: 'Onest', fontSize: 22, color: Colors.black54),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: usernameController,
//               decoration: InputDecoration(
//                 hintText: 'Not visible, just for database',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             GestureDetector(
//               onTap: () {
//                 generateRandomUsername();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(60),
//                 child: Text(
//                   "No ideas? Randomly Generate",
//                   style: TextStyle(
//                     fontFamily: 'Onest',
//                     fontSize: 18,
//                     color: Colors.brown,
//                     fontWeight: FontWeight.w500,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//             // Let's Get Started Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   registerUser();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   elevation: 0,
//                   backgroundColor: Colors.white, // Replaces 'primary'
//                   foregroundColor: Colors.brown, // Replaces 'onPrimary'
//                   side: BorderSide(color: Colors.brown),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: Text(
//                   "Let’s Get Started",
//                   style: TextStyle(fontSize: 24, color: Colors.brown),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
