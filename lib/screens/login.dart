import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'questionaire.dart';
import 'resetPassword.dart';
import '../services/auth_service.dart';
import 'register.dart'; // Import your registration page widget

class LoginPage extends StatelessWidget {
  void _showVerificationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VerificationPopup();
      },
    );
  }
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Debugging: Print email and password
    if (kDebugMode) {
      print("Email: $email");
    }
    if (kDebugMode) {
      print("Password: $password");
    }

    final response = await AuthService.loginUser(email, password);

    if (response.statusCode == 200) {
      // Navigate to HomePage on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const QuestionnairePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to login: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                        height: 350), // Push content below the background image

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
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                            style: const TextStyle(fontSize: 16),
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
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // ElevatedButton(
                    //   onPressed: () => _showVerificationPopup(context),
                    //   child: Text('Login'),
                    // ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showVerificationPopup(context),
                        child: const Text(
                          "Forget Password?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color:
                                Color.fromARGB(255, 156, 93, 93), // Text color
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    OutlinedButton(
                      onPressed: () => loginUser(context),
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
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 156, 93, 93), // Text color
                          // Button text color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Registration Redirect
                    GestureDetector(
                        onTap: () {
                          // Navigate to Registration Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Register()),
                          );
                        },
                        child: Row(
                          
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(
                                    255, 156, 93, 93), // Text color
                                // Text color
                              ),
                            ),
                            const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(
                                    255, 156, 93, 93), // Text color
                                // Text color
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


