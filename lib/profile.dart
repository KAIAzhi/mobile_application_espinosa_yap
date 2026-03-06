import 'package:flutter/material.dart';
import 'home.dart';
import 'reports.dart';
import 'maps.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeWidget()),
        );
        break;
      case 1:
        // Reports tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportsWidget()),
        );
        break;
      case 2:
        // Profile tab - already here
        break;
      case 3:
        // Maps tab
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HazardDetailsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1976D2), // Blue color for selected items
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Maps',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.settings)
                    ],
                  ),
                ),

                /// PROFILE
                Center(
                  child: Column(
                    children: [

                      Stack(
                        children: [

                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: const Text(
                              "JD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Juan Dela Cruz",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Community Responder • Zone 2",
                        style: TextStyle(color: Colors.grey),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// REPORT CARDS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [

                      Expanded(
                        child: statCard("12", "TOTAL REPORTS", Colors.blue),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard("9", "VERIFIED", Colors.green),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// PERSONAL INFO
                sectionTitle("PERSONAL INFORMATION"),

                infoTile(
                    Icons.email_outlined,
                    "Email Address",
                    "juan.delacruz@email.com"
                ),

                infoTile(
                    Icons.phone_android,
                    "Mobile Number",
                    "+63 912 345 6789"
                ),

                const SizedBox(height: 20),

                /// SETTINGS
                sectionTitle("APP SETTINGS"),

                switchTile("Dark Mode", Icons.dark_mode),

                switchTile("Push Notifications", Icons.notifications),

                listTile("Account Security", Icons.security),

                const SizedBox(height: 20),

                /// SIGN OUT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.logout),
                    label: const Text("Sign Out"),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "RescueHub v2.4.1 (Stable Build)",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// STAT CARD
  Widget statCard(String number, String label, Color color) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION TITLE
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// INFO TILE
  Widget infoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  /// SWITCH TILE
  Widget switchTile(String title, IconData icon) {
    return SwitchListTile(
      value: false,
      onChanged: (val) {},
      secondary: Icon(icon),
      title: Text(title),
    );
  }

  /// NORMAL TILE
  Widget listTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}