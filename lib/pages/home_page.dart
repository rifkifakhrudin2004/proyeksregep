import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Function to handle menu item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to corresponding pages
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/camera');
        break;
      case 1:
        Navigator.pushNamed(context, '/storage');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      case 3:
        _logout();
        break;
    }
  }

  // Logout function
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    // Getting device screen size
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 197, 123, 123), // Solid background color
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Padding based on screen width
            child: Text(
              'Selamat datang di Aplikasi Deteksi Wajah',
              style: TextStyle(
                fontSize: screenWidth * 0.06, // Dynamic text size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      // Bottom navigation bar with custom layout
      bottomNavigationBar: Container(
        height: 80.0, // Height for the bottom navigation bar
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
          children: [
            Expanded(
              child: _buildNavItem(
                icon: Icons.person,
                label: 'Profil',
                onTap: () => _onItemTapped(2),
              ),
            ),
            Expanded(
              child: _buildCameraButton(),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.storage,
                label: 'Galeri',
                onTap: () => _onItemTapped(1),
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30), // Adjusted icon size
            Text(label, style: TextStyle(color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(0), // Go to camera
      child: Container(
        height: 60.0, // Adjusted height for the camera button
        width: 60.0, // Adjusted width for the camera button
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 194, 114, 114), // Consistent button color
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.add_a_photo, size: 30.0, color: Colors.white), // Smaller icon size
      ),
    );
  }
}
