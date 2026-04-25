import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social App',
      theme: ThemeData(
        primaryColor: const Color(0xFF009688),
        fontFamily: 'Roboto', // Or your preferred font
        useMaterial3: true,
      ),
      // The app starts here
      home: const OnboardingScreen(), 
    );
  }
}