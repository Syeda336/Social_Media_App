import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

////////////////////////////////////////////////////////
/// ---------------- LOGIN SCREEN ----------------
////////////////////////////////////////////////////////
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
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
          !_emailController.text.contains("@") ? "Enter valid email" : null;

      _passwordError =
          _passwordController.text.length < 6 ? "Password too short" : null;
    });

    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception("Login failed");

      final metadata = user.userMetadata ?? {};

      final appUser = UserModel.fromMap({
        "id": user.id,
        "fullName": metadata["full_name"] ?? "",
        "username": _emailController.text.split("@")[0],
        "bio": "New user",
        "phone": metadata["phone"] ?? "",
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Navigation()),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) return;

    await Supabase.instance.client.auth.resetPasswordForEmail(
      _emailController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password reset email sent")),
    );
  }

  void _goToSignUp() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SignUpScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                  const Text("Welcome Back",
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),

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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _forgotPassword,
                        child: const Text("Forgot Password?"),
                      ),
                      TextButton(
                        onPressed: _goToSignUp,
                        child: const Text("Sign up"),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
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

////////////////////////////////////////////////////////
/// ---------------- SIGNUP SCREEN ----------------
////////////////////////////////////////////////////////
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

  void _goToLogin() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          "full_name": _nameController.text.trim(), // ✅ Display Name
          "phone": _phoneController.text.trim(),    // ✅ Metadata only
        },
      );

      final user = res.user;
      if (user == null) throw Exception("Signup failed");

      final appUser = UserModel.fromMap({
        "id": user.id,
        "fullName": _nameController.text.trim(),
        "username": _emailController.text.split("@")[0],
        "bio": "New user",
        "phone": _phoneController.text.trim(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Navigation()),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: Colors.transparent),
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
                  const Text("Sign Up",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  CustomTextField(
                      hint: "Email",
                      icon: Icons.email,
                      controller: _emailController),

                  CustomTextField(
                      hint: "Full Name",
                      icon: Icons.person,
                      controller: _nameController),

                  CustomTextField(
                      hint: "Phone",
                      icon: Icons.phone,
                      controller: _phoneController),

                  CustomTextField(
                      hint: "Password",
                      icon: Icons.lock,
                      controller: _passwordController,
                      isPassword: true),

                  CustomTextField(
                      hint: "Confirm Password",
                      icon: Icons.lock,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      errorText: _confirmPasswordError),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text("Login"),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerUser,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register"),
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