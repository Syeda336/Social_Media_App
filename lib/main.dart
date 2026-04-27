import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:provider/provider.dart';

// Internal files
import 'authentication.dart';
import 'navigation_bar.dart';
import 'user_model.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://cwiojzbucfmwfltvzugj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3aW9qemJ1Y2Ztd2ZsdHZ6dWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjU1NTMsImV4cCI6MjA5MjcwMTU1M30.5YY6jHqaZ9fkEGN6iR_bYkEmfrmOIMPogv8enZY0EIQ',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SocialApp(),
    ),
  );
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social App',

      themeMode: themeProvider.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009688),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009688),
          brightness: Brightness.dark,
        ),
      ),

      home: const AuthWrapper(),
    );
  }
}

// ---------------- AUTH WRAPPER ----------------
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Key _refreshKey = UniqueKey();

  Future<UserModel> _getProfileData(User firebaseUser) async {
    final supabase = Supabase.instance.client;

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', firebaseUser.uid)
          .maybeSingle();

      if (data != null) {
        return UserModel(
          id: firebaseUser.uid,
          fullName: data['full_name'] ?? "User",
          username: data['username'] ?? "user",
          bio: data['bio'] ?? "",
          avatarUrl: data['avatar_url'],
        );
      }
    } catch (e) {
      debugPrint("Profile error: $e");
    }

    return UserModel(
      id: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? "User",
      username: firebaseUser.email?.split('@').first ?? "user",
      bio: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return FutureBuilder<UserModel>(
          key: _refreshKey,
          future: _getProfileData(firebaseUser),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Navigation(
            );
          },
        );
      },
    );
  }
}