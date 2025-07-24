
import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../components/loading_indicator.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codenameController = TextEditingController();
  String _recipientCodename = '';
  String _message = '';
  List<Message> _messages = [];
  bool _isLoading = false;
  final _apiService = ApiService();
  final _authService = AuthService();
  int? userId;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');

    setState(() {
      userId = id;
    });
  }

  Future<void> _checkAuth() async {
    if (!await _authService.isAuthenticated()) {
      await _authService.logout(context);
    }
  }

  Future<void> _initiateChat() async {
    setState(() => _isLoading = true);
    await _authService.handleApiCall(context, () async {
      await _apiService.initiateChat(_recipientCodename);
      await _fetchMessages();
    });
    setState(() => _isLoading = false);
  }

  Future<void> _sendMessage() async {
    if (_message.isEmpty) return;
    await _authService.handleApiCall(context, () async {
      await _apiService.sendMessage(_recipientCodename, _message);
      await _fetchMessages();
      setState(() => _message = '');
    });
  }

  Future<void> _fetchMessages() async {
    await _authService.handleApiCall(context, () async {
      final messages = await _apiService.getMessages(_recipientCodename);
      setState(() => _messages = messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'SecureChat',
          style: TextStyle(
            color: Color(0xFF1E88E5),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF1E88E5)),
            onPressed: () => _authService.logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Contact search section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFE),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      onChanged: (value) => _recipientCodename = value,
                      decoration: InputDecoration(
                        hintText: 'Enter recipient codename',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF1E88E5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _isLoading
                      ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                      : IconButton(
                    icon: Icon(Icons.chat, color: Colors.white),
                    onPressed: _initiateChat,
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByUser = message.senderId == userId;
                return Align(
                  alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Color(0xFF1E88E5) : Color(0xFFF8FAFE),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isSentByUser ? Radius.circular(4) : Radius.circular(20),
                        bottomLeft: isSentByUser ? Radius.circular(20) : Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isSentByUser ? Colors.white : Color(0xFF2C3E50),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFE),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      onChanged: (value) => _message = value,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}