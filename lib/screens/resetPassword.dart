import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  const PasswordResetScreen({super.key, required this.email});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String error = '';

  Future<void> resetPassword() async {
    final newPassword = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (newPassword != confirm) {
      setState(() => error = 'Passwords do not match');
      return;
    }

    final response = await http.post(
      // Uri.parse('http://localhost:5002/api/auth/reset-password'),
            Uri.parse('http://192.168.1.18:5002/api/auth/reset-password'),

      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        error = jsonDecode(response.body)['message'] ?? 'Reset failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(children: [
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
            child: Column(children: [
              const SizedBox(height: 270),
              buildField("Password", passwordController, false),
              const SizedBox(height: 20),
              buildField("Confirm Password", confirmPasswordController, true),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: resetPassword,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC3B5AC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                child: const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 156, 93, 93),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget buildField(
      String label, TextEditingController controller, bool confirm) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6C635D))),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ),
    ]);
  }
}
