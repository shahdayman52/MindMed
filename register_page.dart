import 'package:flutter/material.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _generatedUsername = '';

  void _generateUsername() {
    setState(() {
      _generatedUsername =
          'user_' + DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  void _registerUser() async {
    String nickname = _nicknameController.text;
    String username = _generatedUsername.isEmpty
        ? _usernameController.text
        : _generatedUsername;

    // Simulating user registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width, // Full width
        height: MediaQuery.of(context).size.height, // Full height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/register_background2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 100, 0, 0),
              child: Text(
                "Welcome!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily: 'RobotoLight'),
              ),
            ),
            SizedBox(height: 100),
            Column(
              children: [
                Container(
                  width: 400.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'What do you like to be called?',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                      SizedBox(
                          height: 20), // Space between text and input field

                      // Rounded container to serve as the input field with shadow
                      Container(
                        width: 350,
                        padding: EdgeInsets.fromLTRB(40, 10, 0, 0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                              75, 182, 206, 182), // Light background color
                          borderRadius:
                              BorderRadius.circular(5.0), // Rounded corners
                          // boxShadow: [
                          //   BoxShadow(
                          //     color:
                          //         Colors.black.withOpacity(0.2), // Shadow color
                          //     spreadRadius: 1, // Spread radius
                          //     blurRadius: 5, // Blur radius
                          //     offset: Offset(0, 2), // Offset for the shadow
                          //   ),
                          // ],
                        ),
                        child: TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            border: InputBorder.none, // No border
                            hintText: 'Enter your nickname',
                            hintStyle: TextStyle(
                                color: Colors.grey[600]), // Hint text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          'Enter Username:',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontFamily: 'RobotoLight'),
                        ),
                      ),
                      SizedBox(
                          height: 20), // Space between text and input field

                      // Rounded container to serve as the input field with shadow
                      Container(
                        width: 350,
                        padding: EdgeInsets.fromLTRB(40, 10, 0, 0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                              75, 182, 206, 182), // Light background color
                          borderRadius:
                              BorderRadius.circular(5.0), // Rounded corners
                          // boxShadow: [
                          //   BoxShadow(
                          //     color:
                          //         Colors.black.withOpacity(0.2), // Shadow color
                          //     spreadRadius: 1, // Spread radius
                          //     blurRadius: 5, // Blur radius
                          //     offset: Offset(0, 2), // Offset for the shadow
                          //   ),
                          // ],
                        ),
                        child: TextField(
                          controller:
                              _usernameController, // Fixed the controller
                          decoration: InputDecoration(
                            border: InputBorder.none, // No border
                            hintText: 'Just for database!',
                            hintStyle: TextStyle(
                                color: Colors.grey[600]), // Hint text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No ideas?",
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: _generateUsername,
                  child: Text(
                    'Randomly Generate',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(
                          255, 6, 105, 109), // Set text color to black
                      decoration:
                          TextDecoration.underline, // Underline the text
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
            Row(
              children: [
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 40, 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Color.fromARGB(255, 6, 105, 109), // Background color
                      shape: BoxShape.circle, // Makes the container circular
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward, // Your icon
                        color: Colors.white,
                        size: 38, // Icon color
                      ),
                      onPressed: _registerUser,
                      padding:
                          EdgeInsets.all(20), // Padding to increase button size
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
