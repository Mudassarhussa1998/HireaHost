import 'package:flutter/material.dart';



class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support Center',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color.fromRGBO(248, 243, 243, 1),
              fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 164, 32, 231),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title Section
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Email
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email Us'),
              subtitle: const Text('mudassarhussa1998@egmail.com \narslanmalik@gmail.com'),
              
              onTap: () {
                // Add email logic
              },
            ),
            const Divider(),
            // Contact Number
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Us'),
              subtitle: const Text('+92 304 565 0316 \n+92 333 565 0316'),
              onTap: () {
                // Add call logic
              },
            ),
            const Divider(),
            // Facebook
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blueAccent),
              title: const Text('Facebook'),
              subtitle: const Text('facebook.com/yourpage'),
              onTap: () {
                // Add Facebook navigation logic
              },
            ),
            const Divider(),
            // Instagram
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              subtitle: const Text('@yourprofile'),
              onTap: () {
                // Add Instagram navigation logic
              },
            ),
            const Divider(),
            // Website
            ListTile(
              leading: const Icon(Icons.web, color: Colors.orange),
              title: const Text('Visit our Website'),
              subtitle: const Text('www.example.com'),
              onTap: () {
                // Add website navigation logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
