import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // Update to use the correct IP for your network (use 10.0.2.2 for Android Emulator)
  static const String _baseUrl =
      'http://localhost:5001/api/auth'; // For Android Emulator

  static Future<http.Response> registerUser(
      String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      // Debugging: print the status and response body
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to register user');
    }
  }

  static Future<http.Response> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Debugging: print the status and response body
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to login user');
    }
  }
}
