import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'navigation_bar.dart'; // Uncomment this when your file is ready

const Color primaryTeal = Color(0xFF009688);
const Color secondarySlate = Color(0xFF263238);
const Color bgColor = Color(0xFFF5F7F9);

// --- Custom Text Field with Visibility Toggle & Validation ---
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
          prefixIcon: Icon(widget.icon, color: Colors.grey, size: 20),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  bool _validate() {
    setState(() {
      _emailError = !_emailController.text.endsWith("@gmail.com") ? "Must end with @gmail.com" : null;
      _passwordError = !RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(_passwordController.text)
          ? "8+ chars, 1 Capital, 1 Number, 1 Special"
          : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Navigation()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: secondarySlate)),
                  const SizedBox(height: 30),
                  CustomTextField(hint: "Email", icon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                  CustomTextField(hint: "Password", icon: Icons.lock_outline, isPassword: true, controller: _passwordController, errorText: _passwordError),
                  
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Enter", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Google Sign In Button
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                      label: const Text("Continue with Google", style: TextStyle(color: secondarySlate)),
                      onPressed: () {/* Implement Google Auth Logic */},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(context, _createRoute(const SignUpScreen())),
                        child: const Text("Sign up", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {/* Forgot Password Logic */},
                        child: const Text("Forget Password", style: TextStyle(color: Colors.grey)),
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

// --- 2. SIGN UP SCREEN ---
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
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _emailError, _passError;

  bool _validate() {
    setState(() {
      _emailError = !_emailController.text.endsWith("@gmail.com") ? "Must end with @gmail.com" : null;
      _passError = !RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(_passwordController.text)
          ? "8+ chars, 1 Capital, 1 Number, 1 Special"
          : null;
    });
    return _emailError == null && _passError == null;
  }

  Future<void> _registerUser() async {
  if (!_validate()) return;
  setState(() => _isLoading = true);

  try {
    // 1. Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 2. Supabase Insert
    // We use a try-catch specifically for the DB insert to see exactly what fails
    try {
      await Supabase.instance.client.from('users').insert({
        'firebase_uid': userCredential.user!.uid,
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_no': _phoneController.text.trim(),
      });
    } catch (dbError) {
      print("Supabase specific error: $dbError");
      // If DB fails, you might want to delete the Firebase user to keep them in sync
      await userCredential.user!.delete(); 
      throw "Database sync failed. Please try again."; // <--- THIS IS WHAT YOU SAW
    }

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Navigation()));
    }
  } catch (e) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: secondarySlate)),
                  const SizedBox(height: 30),
                  CustomTextField(hint: "Email", icon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                  CustomTextField(hint: "Name", icon: Icons.person_outline, controller: _nameController),
                  CustomTextField(hint: "Phone No.", icon: Icons.phone_outlined, controller: _phoneController),
                  CustomTextField(hint: "Password", icon: Icons.lock_outline, isPassword: true, controller: _passwordController, errorText: _passError),
                  CustomTextField(hint: "Confirm Password", icon: Icons.lock_outline, isPassword: true, controller: _confirmController),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Enter", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Login", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
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

// --- Helper for Route ---
Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}