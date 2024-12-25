import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ChatBotService {
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";
  static const String apiKey = "AIzaSyCSzGCwCX8s1hMpQZrLZSRq3zidCYu-RzM";

  static Future<String> sendMessage(String message) async {
    try {
      final headers = {"Content-Type": "application/json"};
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('candidates') &&
            data['candidates'] != null &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null) {
          return data['candidates'][0]['content']['parts'][0]['text'] ??
              "No response from AI";
        } else {
          return "No valid content in the response";
        }
      } else {
        return "Error: ${response.statusCode}, ${response.body}";
      }
    } catch (e) {
      return "Error: Unable to send message. $e";
    }
  }
}

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController aiChatInputController = TextEditingController();
  final List<Map<String, String>> messages = [];

  void sendMessage() async {
    final userInput = aiChatInputController.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': userInput});
      aiChatInputController.clear();
    });

    final aiResponse = await ChatBotService.sendMessage(userInput);

    setState(() {
      messages.add({'role': 'bot', 'text': aiResponse});
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
            size: 20,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        title: Text(
          "Hire Host AI",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/home');
              
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage('assets/robot.gif'),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChatBot()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 0, 0, 0) : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: aiChatInputController,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white), // Set the text color to white
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.grey), // Optional: change hint text color
                      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
                        ),
                      ),
                    ),
                  )

                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black, size: 28),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
