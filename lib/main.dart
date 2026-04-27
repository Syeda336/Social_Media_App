import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

// Internal files
import 'authentication.dart';
import 'navigation_bar.dart';
import 'user_model.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Initialize Supabase
  await Supabase.initialize(
    url: 'https://cwiojzbucfmwfltvzugj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW9qemJ1Y2Ztd2ZsdHZ6dWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjU1NTMsImV4cCI6MjA5MjcwMTU1M30.5YY6jHqaZ9fkEGN6iR_bYkEmfrmOIMPogv8enZY0EIQ',
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009688),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // 🔹 Convert Firebase User → UserModel
  UserModel _generateUserModel(User firebaseUser) {
    String name = firebaseUser.displayName ?? "New User";

    return UserModel(
      id: firebaseUser.uid, // ✅ FIXED
      fullName: name,
      username: firebaseUser.email?.split('@').first ?? "user",
      bio: "Digital Creator | Content Enthusiast",
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF009688),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          return const OnboardingScreen();
        }

        final userModel = _generateUserModel(snapshot.data!);
        return Navigation(user: userModel);
      },
    );
  }
}