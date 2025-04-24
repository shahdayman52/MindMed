import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mindmed/config.dart';

class AuthService {
  //CHANGE IN FGT PWD,MOODLOG,MOOD DASHBOARD, OTP,reset pw
  static const String _baseUrl = 'http://$BaseUrl1/api/auth';
  // static const String _baseUrl =
  //     'http://192.168.1.18:5002/api/auth'; // use your IP here
  static const String _postBase = 'http://$BaseUrl1/api/posts';
  // static const String _postBase =
  //     'http://192.168.1.18:5002/api/posts'; // use your IP here
  static const String _journalBase = 'http://$BaseUrl1/api/journal';
  // static const String _journalBase =
  //     'http://192.168.1.18:5002/api/journal'; // use your IP here
  static const String _questionnaireBase =
      'http://$BaseUrl1/api/questionnaire';
  // static const String _questionnaireBase =
  //     'http://192.168.1.18:5002/api/questionnaire'; // use your IP here

  // ✅ Register User
  static Future<http.Response> registerUser(
      String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    
    return response;
  }

//login user
  static Future<bool> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final username = data['user']['name'];
      final userId = data['user']['_id'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      await prefs.setString('userId', userId);

      return true; // ✅ indicate success
    } else {
      print("Login failed: ${response.body}");
      return false; // ❌ login failed
    }
  }

  // ✅ Get Token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // // ------------------------------------------ OTP RESET ------------------------------------------------------ //
  static Future<bool> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> resetPassword(String email, String newPassword) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );
    return res.statusCode == 200;
  }

//Questionnaire
  static Future<void> submitQuestionnaire(
      List<String> answers, int stressLevel) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';

    final url = Uri.parse('$_questionnaireBase/submit');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'answers': answers,
        'stressLevel': stressLevel,
      }),
    );

    if (response.statusCode != 201) {
      print("❌ Submission Failed: ${response.statusCode}");
      print("❌ Response body: ${response.body}");
      throw Exception("Failed to submit questionnaire");
    }
  }

  static Future<bool> checkQuestionnaireStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    final url = Uri.parse('$_questionnaireBase/status/$userId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['completed'];
    }
    return false;
  }

  // ✅ Logout
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
     await prefs.clear(); // clears all keys including 'username'

    print("Token after logout: ${prefs.getString('token')}");
    print("Username after logout: ${prefs.getString('username')}");
  }

  // ---------------- COMMUNITY ---------------- //

  // ✅ Create Post
  static Future<http.Response> createPost(String content) async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/createPost');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    print("📡 POST URL: $url");
    print("📤 POST RESPONSE: ${response.statusCode} ${response.body}");

    return response;
  }

  // ✅ Get All Posts
  static Future<http.Response> getAllPosts() async {
    final url = Uri.parse('$_postBase/allPosts');
    return await http.get(url);
  }

  // ✅ Get My Posts
  static Future<http.Response> getMyPosts() async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/myPosts');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ✅ Relate to a Post
  static Future<http.Response> relatePost(String postId) async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/$postId/relate');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("🔥 Relate response: ${response.statusCode} ${response.body}");

    return response;
  }

  // ✅ Delete Post
  static Future<void> deletePost(String postId) async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/$postId');

    await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ✅ Delete Comment
  static Future<http.Response> deleteComment(String commentId) async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/deleteComment/$commentId');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to delete comment: ${response.body}');
      }
    } catch (error) {
      print('🧨 Error deleting comment: $error');
      throw Exception('Error deleting comment');
    }
  }

  // ✅ Add Comment
  static Future<http.Response> addComment(String postId, String text) async {
    final token = await getToken();
    final url = Uri.parse('$_postBase/addComment/$postId');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': text}),
    );
  }

  // ✅ Get Comments
  static Future<http.Response> getComments(String postId) async {
    final url = Uri.parse('$_postBase/getComment/$postId');
    return await http.get(url);
  }

  // -------------------------------------------------- Journal -------------------------------------------------- //
// ✅ Save Journal
  static Future<http.Response> saveJournal(
      String title, String content, String sentiment) async {
    final token = await getToken();
    final url = Uri.parse('$_journalBase/writeJournal');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'sentiment': sentiment,
      }),
    );

    return response;
  }

  // ✅ Get all journals
  static Future<List<Map<String, dynamic>>> getMyJournals() async {
    final token = await getToken();
    final url = Uri.parse('$_journalBase/myJournals');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load journals: ${response.statusCode}");
    }
  }

  //✅delete journal
  static Future<void> deleteJournal(String journalId) async {
    final token = await getToken();
    final url = Uri.parse('$_journalBase/$journalId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("Deleting journal with ID: $journalId");
    print("🗑️ Delete Response: ${response.statusCode} - ${response.body}");

    print("🗑️ Delete Response: ${response.statusCode} - ${response.body}");
  }

// ----------
}
