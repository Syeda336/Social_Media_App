import 'package:flutter/material.dart';
import 'profile_screen.dart'; 
import 'user_model.dart';
// 1. Ensure you have supabase_flutter in your pubspec.yaml
import 'package:supabase_flutter/supabase_flutter.dart';

// --- MAIN NAVIGATION SHELL ---
class Navigation extends StatefulWidget {
  final UserModel user;
  const Navigation({super.key, required this.user});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  final Color primaryTeal = const Color(0xFF009688);
  final Color inactiveGrey = Colors.grey.shade600;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(user: widget.user), 
      const Center(child: Text("Documents", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Chat", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Search", style: TextStyle(fontSize: 24))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: primaryTeal, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 65,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 0),
            _buildNavItem(Icons.description_outlined, Icons.description, 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 2),
            _buildNavItem(Icons.search, Icons.search, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData inactiveIcon, IconData activeIcon, int index) {
    bool isActive = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive ? primaryTeal : inactiveGrey,
        size: 28,
      ),
    );
  }
}

// --- HOME SCREEN CONTENT ---
class HomeScreen extends StatelessWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  final Color primaryTeal = const Color(0xFF009688);

  // 2. SUPABASE FETCH LOGIC
  Future<String> _fetchUserNameFromSupabase() async {
    try {
      // Queries the 'users' table where the 'id' matches the current user
      final data = await Supabase.instance.client
          .from('users')
          .select('full_name') // or 'fullName' depending on your column name
          .eq('id', user.id)
          .single();

      if (data != null && data['full_name'] != null) {
        return data['full_name'] as String;
      }
    } catch (e) {
      debugPrint("Supabase Error: $e");
    }
    return user.fullName; // Fallback to current local data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: FutureBuilder<String>(
          future: _fetchUserNameFromSupabase(),
          builder: (context, snapshot) {
            // Displays Supabase name, or initial name while loading
            String displayName = snapshot.data ?? user.fullName;
            return Text(
              displayName,
              style: const TextStyle(
                color: Color(0xFF263238),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: primaryTeal,
                child: Text(
                  user.initials, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => _buildBlankFeedCard(),
      ),
    );
  }

  // --- UI Helpers (Remaining code exactly as original) ---
  Widget _buildBlankFeedCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreyBar(height: 24, width: 200),
                const SizedBox(height: 12),
                _buildGreyBar(height: 16),
                const SizedBox(height: 8),
                _buildGreyBar(height: 16),
                const SizedBox(height: 8),
                _buildGreyBar(height: 16, width: 150),
                const SizedBox(height: 16),
                const Divider(),
                const Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlankIconButton(icon: Icons.thumb_up_alt_outlined),
                    BlankIconButton(icon: Icons.thumb_down_alt_outlined),
                    Spacer(),
                    BlankIconButton(icon: Icons.chat_bubble_outline),
                    SizedBox(width: 20),
                    BlankIconButton(icon: Icons.share_outlined),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreyBar({double height = 16, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class BlankIconButton extends StatelessWidget {
  final IconData icon;
  const BlankIconButton({super.key, required this.icon}); 

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.grey.shade400, size: 22);
  }
}