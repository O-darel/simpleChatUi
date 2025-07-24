// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/message.dart';
//
// class ApiService {
//   static const String _baseUrl = 'http://localhost:3000/api';
//
//   Future<Map<String, dynamic>> signup(String username, String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$_baseUrl/auth/signup'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'email': email,
//         'password': password,
//       }),
//     );
//     return _handleResponse(response);
//   }
//
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$_baseUrl/auth/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'email': email,
//         'password': password,
//       }),
//     );
//     final data = _handleResponse(response);
//     if (data.containsKey('token')) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', data['token']);
//     }
//     return data;
//   }
//
//   Future<void> initiateChat(String recipientCodename) async {
//     final token = await _getToken();
//     final response = await http.post(
//       Uri.parse('$_baseUrl/chat/initiate'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({'recipientCodename': recipientCodename}),
//     );
//     _handleResponse(response);
//   }
//
//   Future<void> sendMessage(String recipientCodename, String content) async {
//     final token = await _getToken();
//     final response = await http.post(
//       Uri.parse('$_baseUrl/chat/message'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'recipientCodename': recipientCodename,
//         'content': content,
//       }),
//     );
//     _handleResponse(response);
//   }
//
//   Future<List<Message>> getMessages(String recipientCodename) async {
//     final token = await _getToken();
//     final response = await http.get(
//       Uri.parse('$_baseUrl/chat/messages/$recipientCodename'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     final data = _handleResponse(response);
//     return List<Map<String, dynamic>>.from(data)
//         .map((json) => Message.fromJson(json))
//         .toList();
//   }
//
//   Future<String> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) throw Exception('No token found');
//     return token;
//   }
//
//   Map<String, dynamic> _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return response.body.isNotEmpty ? jsonDecode(response.body) : {};
//     } else if (response.statusCode == 401) {
//       throw Exception('Unauthorized: Invalid or expired token');
//     } else {
//       throw Exception('Failed with status ${response.statusCode}: ${response.body}');
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ApiService {
  static const String _baseUrl = 'https://7b2d704efe06.ngrok-free.app/api/v1';

  Future<Map<String, dynamic>> signup(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = _handleResponse(response) as Map<String, dynamic>;
    if (data.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
    }
    return data;
  }

  Future<void> initiateChat(String recipientCodename) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/initiate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'recipientCodename': recipientCodename}),
    );
    _handleResponse(response);
  }

  Future<void> sendMessage(String recipientCodename, String content) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'recipientCodename': recipientCodename,
        'content': content,
      }),
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<void> updateProfile(String codename) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'codename': codename}),
    );
    _handleResponse(response);
  }

  Future<List<Message>> getMessages(String recipientCodename) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/chat/messages/$recipientCodename'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = _handleResponse(response);
    if (data is! List) {
      throw Exception('Expected a list of messages, but received: ${data.runtimeType}');
    }
    return data.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');
    return token;
  }

  Future<String> _getCodeName() async {
    final prefs = await SharedPreferences.getInstance();
    final codename = prefs.getString('codename');
    if (codename == null) throw Exception('No codename found');
    return codename;
  }
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId  == null) throw Exception('User id not found');
    return userId ;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed with status ${response.statusCode}: ${response.body}');
    }
  }
}