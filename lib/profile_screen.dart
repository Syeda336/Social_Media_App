import 'package:flutter/material.dart';
import 'authentication.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryTeal = const Color(0xFF009688);
  
  // 1. Track the active tab (0 = Posts, 1 = Videos, 2 = Liked)
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            // --- Updated Header Section (Arrow & ID Row -> Circle & Bio Row) ---
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left side: Vertical stack of content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROW 1: Back Arrow and User ID
            Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF263238), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const Text(
                  "@johndoe",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF263238)
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // ROW 2: JD Circle and Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: primaryTeal,
                  child: const Text(
                    "JD", 
                    style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Doe", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Creative soul | Photography enthusiast | Travel lover",
                        style: TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Right side: Settings Icon (remains at the top right)
      IconButton(
        icon: const Icon(Icons.settings, color: Colors.grey, size: 26),
        onPressed: () {
          // Navigator.push to SettingsScreen
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        },
      ),
    ],
  ),
),

            // --- Tab Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton("Posts", 0),
                  const SizedBox(width: 8),
                  _buildTabButton("Videos", 1),
                  const SizedBox(width: 8),
                  _buildTabButton("Liked", 2),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),

            // --- Dynamic Grid Content ---
            Expanded(
              child: _buildGridContent(),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Helper to build the Tab Buttons
  Widget _buildTabButton(String text, int index) {
    bool isActive = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = index), // Change state on click
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? primaryTeal : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text, 
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ),
      ),
    );
  }

  // 3. Helper to switch the Grid based on activeTab
  Widget _buildGridContent() {
    String label = "";
    IconData icon = Icons.image;
    int count = 6;

    if (activeTab == 0) {
      label = "Post";
      icon = Icons.image_outlined;
      count = 6;
    } else if (activeTab == 1) {
      label = "Video";
      icon = Icons.play_circle_outline;
      count = 4; // Different count to see the change
    } else {
      label = "Liked";
      icon = Icons.favorite_border;
      count = 9; // Different count to see the change
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey.shade400),
              const SizedBox(height: 4),
              Text("$label ${index + 1}", style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final Color primaryTeal = const Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Settings", style: TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSettingToggle(Icons.dark_mode_outlined, "Dark Mode", "Toggle dark/light theme", false),
                  const Divider(),
                  _buildSettingToggle(Icons.notifications_none, "Notifications", "Enable/disable notifications", true),
                  const Divider(),
                  _buildTextSizeSelector(),
                  const Divider(),
                  // --- Added Name Change Option ---
                  _buildSimpleOption(Icons.person_outline, "Name Change", "Update your display name"),
                  const Divider(),
                  _buildSimpleOption(Icons.vpn_key_outlined, "Change Password", "Update your password"),
                ],
              ),
            ),
            const Spacer(),
            // --- Logout Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Navigate to Login and remove all previous screens from stack
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingToggle(IconData icon, String title, String sub, bool val) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon, color: Colors.black87)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: Switch(value: val, onChanged: (v) {}, activeColor: primaryTeal),
    );
  }

  Widget _buildSimpleOption(IconData icon, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: Colors.grey.shade100, child: Icon(icon, color: Colors.black87)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildTextSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey.shade100, child: const Icon(Icons.text_fields, color: Colors.black87)),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Text Size", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Adjust text size", style: TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Small", "Medium", "Large"].map((size) {
              bool isMed = size == "Medium";
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isMed ? primaryTeal : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(size, style: TextStyle(color: isMed ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}