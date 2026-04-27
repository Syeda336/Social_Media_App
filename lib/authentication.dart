import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'navigation_bar.dart';
import 'user_model.dart';

const Color primaryTeal = Color(0xFF009688);
const Color secondarySlate = Color(0xFF263238);
const Color bgColor = Color(0xFFF5F7F9);

/// ---------------- CUSTOM TEXT FIELD ----------------
class CustomTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          prefixIcon: Icon(widget.icon, color: Colors.grey),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// ---------------- LOGIN SCREEN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Added missing state variable

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError =
          !_emailController.text.contains("@") ? "Enter a valid email" : null;

      _passwordError =
          _passwordController.text.length < 6 ? "Password too short" : null;
    });

    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. PRIMARY SEARCH: Search/Authenticate using Supabase Auth
      final supabaseAuthResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Verify we got a user back from Supabase
      if (supabaseAuthResponse.user == null) {
        throw Exception("User not found in Supabase authentication.");
      }

      // 2. BACKGROUND SYNC: Sign into Firebase so both sessions are active
      // We do this after Supabase succeeds since Supabase is now your primary search
      final firebaseCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = firebaseCredential.user!;

      // 3. FETCH PROFILE: Get the user details from your Supabase 'users' table
      // We use the ID linked during registration (which we set as the Firebase UID)
// 3. FETCH PROFILE: Get the user details
final response = await Supabase.instance.client
    .from('users')
    .select()
    .eq('id', firebaseUser.uid)
    .maybeSingle(); // Changed from .single() to .maybeSingle()

if (response == null) {
  throw Exception("User profile not found in database. Please sign up again.");
}

final user = UserModel.fromMap(response);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Navigation(user: user)),
      );
    } on AuthException catch (e) {
  if (e.message.contains("Email not confirmed")) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please check your inbox and confirm your email before logging in.")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Auth Error: ${e.message}")),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("An unexpected error occurred: $e")),
  );
} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your email first")),
      );
      return;
    }

    try {
      // Typically reset via Firebase as it's the primary auth
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: _emailController,
                    errorText: _emailError,
                  ),
                  CustomTextField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: _passwordController,
                    isPassword: true,
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Login"),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _forgotPassword,
                        child: const Text("Forgot Password?"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text("Create Account"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- SIGNUP SCREEN ----------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Passwords do not match");
      return;
    }

    setState(() {
      _confirmPasswordError = null;
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Create User in Firebase Auth
      final firebaseCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Create User in Supabase Auth
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final firebaseUser = firebaseCredential.user!;

      // 3. Prepare data and save to Supabase Database
      final userData = {
        "id": firebaseUser.uid, // Linking both via Firebase UID
        "fullName": _nameController.text.trim(),
        "username": email.split("@")[0],
        "bio": "New user",
        "phone": _phoneController.text.trim(),
      };

      await Supabase.instance.client.from('users').insert(userData);

      final user = UserModel.fromMap(userData);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Navigation(user: user)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Failed: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: secondarySlate),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: secondarySlate,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: _emailController,
                  ),
                  CustomTextField(
                    hint: "Full Name",
                    icon: Icons.person,
                    controller: _nameController,
                  ),
                  CustomTextField(
                    hint: "Phone",
                    icon: Icons.phone,
                    controller: _phoneController,
                  ),
                  CustomTextField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  CustomTextField(
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    errorText: _confirmPasswordError,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Register"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}