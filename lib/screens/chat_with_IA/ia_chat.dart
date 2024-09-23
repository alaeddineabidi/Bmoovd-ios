import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false; // Add this to control typing animation

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        _messages.add({"text": messageText, "sender": "user"});
        _isTyping = true; // Start typing animation
      });
      _controller.clear();
      await _getBotResponse(messageText);
    }
  }

  Future<void> _getBotResponse(String userMessage) async {
    final url = Uri.parse('https://bmoovd-chatbot.onrender.com');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": userMessage}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final botResponse = responseData['response'];
      if (mounted) {
        setState(() {
          _messages.add({"text": botResponse, "sender": "bot"});
          _isTyping = false; // Stop typing animation
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _messages.add({"text": "Erreur de communication avec le serveur.", "sender": "bot"});
          _isTyping = false; // Stop typing animation even in case of error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "ChatBot",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Color(0xffE6E7E9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length + (_isTyping ? 1 : 0), // Add an extra item for typing animation
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  // Show typing indicator
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'en train d\'écrire...',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blueAccent : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Geben Sie Ihre Nachricht ein...",
                      hintStyle: GoogleFonts.plusJakartaSans(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
