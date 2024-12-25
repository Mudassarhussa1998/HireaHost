import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/Pages/Signin.dart';
import 'package:untitled/Pages/signup.dart';
import 'package:untitled/Pages/ThemeManager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoAnimation;
  late Animation<Offset> _textAnimation;
  late Animation<Offset> _robotAnimation;
  late Animation<Offset> _button1Animation;
  late Animation<Offset> _button2Animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Define animations for each element
    _logoAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _textAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _robotAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _button1Animation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _button2Animation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    return Scaffold(
      backgroundColor: themeManager.isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _logoAnimation,
                child: Image.asset(
                  'assets/Homelogo.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  semanticLabel: 'App Logo',
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _textAnimation,
                child: const Text(
                  "Welcome to Hire Host",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              SlideTransition(
                position: _robotAnimation,
                child: Image.asset(
                  'assets/robot.gif',
                  height: 150,
                  width: 150,
                  semanticLabel: 'Robot Icon',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 50),
              SlideTransition(
                position: _button1Animation,
                child: _buildGradientButton(
                  context,
                  "Sign In",
                  
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _button2Animation,
                child: _buildGradientButton(
                  context,
                  "Sign Up",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 73, 149, 212), Colors.purple],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color.fromARGB(255, 162, 162, 162), Color.fromARGB(255, 255, 255, 255)],
          ).createShader(bounds),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                text == "Sign In" ? Icons.login : Icons.app_registration,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
