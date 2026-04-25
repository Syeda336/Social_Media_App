import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'authentication.dart'; // Ensure these imports match your file names
import 'navigation_bar.dart'; 
import 'splash_screen.dart'; // Or splash_screen.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
// Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Supabase 
  // FIX: Removed '/rest/v1/' from the URL. Supabase client adds that automatically.
  await Supabase.initialize(
    url: 'https://cwiojzbucfmwfltvzugj.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW9qemJ1Y2Ztd2ZsdHZ6dWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjU1NTMsImV4cCI6MjA5MjcwMTU1M30.5YY6jHqaZ9fkEGN6iR_bYkEmfrmOIMPogv8enZY0EIQ',
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
        primaryColor: const Color(0xFF009688),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Use a StreamBuilder to check if the user is already logged in
      home: const AuthWrapper(), 
    );
  }
}

// This widget decides whether to show the Login Screen or the Home Screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, they are logged in
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen(); // Or OnboardingScreen() if first time
          }
          return const Navigation(); // Your main app screen
        }
        
        // Show a loading spinner while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF009688))),
        );
      },
    );
  }
}