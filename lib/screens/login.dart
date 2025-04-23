
import 'package:flutter/material.dart';
import 'register.dart';
import 'questionaire.dart';
import 'homepage.dart';
import '../services/auth_service.dart';
import 'forgetpwd.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String error = '';


  Future<void> loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        error = "Email and password cannot be empty.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    bool success = await AuthService.loginUser(email, password);

    setState(() {
      isLoading = false;
    });

   if (success) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print("🔍 [loginUser] userId before checking questionnaire: $userId");

      bool hasCompleted = await AuthService.checkQuestionnaireStatus();
      print(
          "🔍 [loginUser] checkQuestionnaireStatus() returned: $hasCompleted");

      if (!hasCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionnairePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      setState(() {
        error = "Login failed. Please check your credentials.";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 350),

                  // Email Field
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

                  // Password Field
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

                  // Forget Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Forgetpwd()),
                        );
                      },
                      child: const Text(
                        "Forget Password?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 156, 93, 93),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Login Button
                  OutlinedButton(
                    onPressed: () => loginUser(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC3B5AC)),
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
                        color: Color.fromARGB(255, 156, 93, 93),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),

                  const SizedBox(height: 20),

                  // Sign-up redirect
                  GestureDetector(
                    onTap: () {
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
                            color: Color.fromARGB(255, 156, 93, 93),
                          ),
                        ),
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 156, 93, 93),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



