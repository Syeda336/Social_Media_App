import 'package:flutter/material.dart';
import 'profile_screen.dart';

// --- MAIN NAVIGATION SHELL ---
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final Color primaryTeal = const Color(0xFF009688);
  final Color inactiveGrey = Colors.grey.shade600;

  // This list holds the different screens for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(), // Index 0: Your Home Screen code
      const Center(child: Text("Documents", style: TextStyle(fontSize: 24))), // Index 1
      const Center(child: Text("Chat", style: TextStyle(fontSize: 24))),      // Index 2
      const Center(child: Text("Search", style: TextStyle(fontSize: 24))),    // Index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // IndexedStack keeps the state of screens alive when switching tabs
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
            const SizedBox(width: 40), // Gap for FAB
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
// Note: Removed the Scaffold and BottomBar from here as they are now in 'Navigation'
// --- FIXED HOME SCREEN CONTENT ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryTeal = const Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold here but WITHOUT a bottomNavigationBar 
    // This provides the correct constraints for the AppBar and Body
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "John Doe",
          style: TextStyle(
            color: Color(0xFF263238),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: primaryTeal,
              child: const Text("JD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
      ),
      // By using ListView directly as the body of this inner Scaffold, 
      // we avoid the Column/Expanded height conflict entirely.
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) => _buildBlankFeedCard(),
      ),
    );
  }

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
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BlankIconButton(icon: Icons.thumb_up_alt_outlined),
                    const BlankIconButton(icon: Icons.thumb_down_alt_outlined),
                    const Spacer(),
                    const BlankIconButton(icon: Icons.chat_bubble_outline),
                    const SizedBox(width: 20),
                    const BlankIconButton(icon: Icons.share_outlined),
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
  // This 'const' here is what allows you to use it in constant lists!
  const BlankIconButton({super.key, required this.icon}); 

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.grey.shade400, size: 22);
  }
}