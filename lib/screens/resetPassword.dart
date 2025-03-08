import 'package:flutter/material.dart';


class VerificationPopup extends StatelessWidget {
  void _showEmailSentPopup(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EmailSentPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A verification email will be sent to you!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => _showEmailSentPopup(context), child: Text('Ok', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Set button border radius
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),))),
        ],
      ),
    );
  }
}

class EmailSentPopup extends StatelessWidget {
  void _navigateToResetPassword(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PasswordResetScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
            backgroundColor: Colors.white,

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Text(
            'We have sent an email to you!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text("Didn't receive? Resend",style: TextStyle(color: Colors.black)),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => _navigateToResetPassword(context),
              child: Text('Accept',style: TextStyle(color: Colors.black),),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ))),
        ],
      ),
    );
  }
}

class PasswordResetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/registrationbackground.png'), // Set your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 270,
                    ),
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
                      "Confirm Password",
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

                const SizedBox(height: 20),
                // Login Button
                OutlinedButton(
                  onPressed: () {},
                  // => loginUser(context),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}


  