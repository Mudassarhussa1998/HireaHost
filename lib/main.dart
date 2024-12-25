import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/Signin.dart';
import 'Pages/companydetails.dart';
import 'Pages/cv.dart';
import 'Pages/helpcenter.dart';
import 'Pages/hireahost.dart';
import 'Pages/homepage.dart';
import 'Pages/profile.dart';
import 'Pages/search.dart';
import 'Pages/signup.dart';
import 'Pages/welcome.dart';
import 'Pages/ThemeManager.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'Pages/chatbotservices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      initialRoute: '/welcome', // Define the initial route
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/': (context) => const ProfileScreen(),
        '/page2': (context) => const JobVacancyScreen(),
        '/cv': (context) => const CVScreen(),
        '/help': (context) => const HelpAndSupportPage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => HomePage(),
        '/search': (context) => SearchPage(searchController: TextEditingController(), query: '',),
        '/details': (context) => const DetailsPage(),
        '/chatbot': (context) => const ChatBot(),
      },
    );
  }
}
