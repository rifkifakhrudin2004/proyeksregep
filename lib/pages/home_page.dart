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
      appBar: AppBar(
        title: Text('SREGEP'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, color: Colors.blueAccent),
                      Text('Profil', style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Container(
                  height: 50.0, // Adjusted height for the camera button
                  width: 50.0, // Adjusted width for the camera button
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: Icon(Icons.add_a_photo, size: 30.0, color: Colors.white), // Smaller icon size
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/storage');
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storage, color: Colors.blueAccent),
                      Text('Galeri', style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: _logout,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.blueAccent),
                      Text('Logout', style: TextStyle(color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
