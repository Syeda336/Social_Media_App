import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'authentication.dart';

// ---------------- PROFILE SCREEN ----------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final Color primaryTeal = const Color(0xFF009688);

  String? fullName;
  String? username;
  String? bio;
  String? avatarUrl;

  bool _isLoading = true; 
  bool _isUploading = false;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------- LOAD USER (FIXED) ----------------
  Future<void> _loadUser() async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    if (mounted) setState(() => _isLoading = false);
    return;
  }

  try {
    if (mounted) {
      setState(() {
        // From Supabase Auth (NOT users table)
        fullName = user.userMetadata?['full_name'] ??
            user.email?.split('@').first ??
            "User";

        username = user.email?.split('@').first;

        // If you want email shown anywhere
        bio = user.email;

        avatarUrl = null; // optional since no table is used

        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint("Auth load error: $e");
    if (mounted) setState(() => _isLoading = false);
  }
}

  // ---------------- PICK + UPLOAD (FIXED) ----------------
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final user = supabase.auth.currentUser!;
      final file = File(picked.path);
      
      // Using a unique filename prevents old images from showing due to CDN caching
      final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = 'public/${user.id}/$fileName';

      await supabase.storage.from('avatars').upload(
        path, 
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final String imageUrl = supabase.storage.from('avatars').getPublicUrl(path);

      // Update the database so it persists across logins
      await supabase.from('users').update({'avatar_url': imageUrl}).eq('id', user.id);

      setState(() {
        avatarUrl = "$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}";
        _isUploading = false;
      });
    } catch (e) {
      debugPrint("Upload Error: $e");
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "@${username ?? 'user'}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                      if (result == true) _loadUser();
                    },
                  ),
                ],
              ),
            ),
            // PROFILE INFO
            Row(
              children: [
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryTeal,
                        backgroundImage: (avatarUrl != null) 
                            ? NetworkImage(avatarUrl!) 
                            : null,
                        child: (avatarUrl == null)
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName ?? "User", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(bio ?? "", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _tab("Posts", 0),
                _tab("Videos", 1),
                _tab("Liked", 2),
              ],
            ),
            const Divider(),
            Expanded(child: _grid()),
          ],
        ),
      ),
    );
  }

  Widget _tab(String text, int index) {
    bool isActive = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = index),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: isActive ? primaryTeal : Colors.grey.shade200,
          child: Center(
            child: Text(text, style: TextStyle(color: isActive ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => Container(decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
    );
  }
}

// ---------------- SETTINGS SCREEN ----------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;

  Future<void> _updateField(String field, String value) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      await supabase.from('users').update({field: value}).eq('id', user.id);
      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showEditDialog(String field, String title) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _updateField(field, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldCtr = TextEditingController();
    final newCtr = TextEditingController();
    final confCtr = TextEditingController();
    bool obs1 = true, obs2 = true, obs3 = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: const Text("Change Password"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _pField("Old Password", oldCtr, obs1, () => setDState(() => obs1 = !obs1)),
                _pField("New Password", newCtr, obs2, () => setDState(() => obs2 = !obs2)),
                _pField("Confirm Password", confCtr, obs3, () => setDState(() => obs3 = !obs3)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (newCtr.text != confCtr.text) return;
                try {
                  // Verify old password first
                  await supabase.auth.signInWithPassword(
                    email: supabase.auth.currentUser!.email!,
                    password: oldCtr.text.trim(),
                  );
                  // Update to new password
                  await supabase.auth.updateUser(UserAttributes(password: newCtr.text.trim()));
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification Failed")));
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pField(String label, TextEditingController ctr, bool obs, VoidCallback toggle) {
    return TextField(
      controller: ctr,
      obscureText: obs,
      decoration: InputDecoration(
        labelText: label, 
        suffixIcon: IconButton(
          icon: Icon(obs ? Icons.visibility_off : Icons.visibility), 
          onPressed: toggle
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: theme.isDarkMode,
            onChanged: (v) => theme.toggleTheme(v),
          ),
          ListTile(title: const Text("Change Name"), onTap: () => _showEditDialog('full_name', 'Name')),
          ListTile(title: const Text("Update Bio"), onTap: () => _showEditDialog('bio', 'Bio')),
          ListTile(title: const Text("Change Password"), onTap: _changePassword),
          const Divider(),
          ListTile(
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await supabase.auth.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}