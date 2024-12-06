import 'package:flutter/material.dart';
import 'package:proyeksregep/pages/home_page.dart';
import 'package:proyeksregep/pages/storage_page.dart';
import 'package:proyeksregep/pages/profile_page.dart';
import 'package:proyeksregep/pages/routinelist_page.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const CustomBottomNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _navigateToPage(int index, BuildContext context) {
    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = StoragePage();
        break;
      case 2:
        page = SkincareRoutineListPage();
        break;
      case 3:
        page = ProfilePage();
        break;
      default:
        page = HomePage(); // Default to HomePage
    }

    // Use PageRouteBuilder for smooth transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Apply a fade transition
          var begin = 0.0;
          var end = 1.0;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var opacity = animation.drive(tween);

          return FadeTransition(opacity: opacity, child: child); // Smooth fade transition
        },
        transitionDuration: const Duration(milliseconds: 100), // Adjust duration for smoother transition
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update selected index on tap
        });
        _navigateToPage(index, context);
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index
                  ? const Color.fromRGBO(236, 64, 122, 1)
                  : const Color.fromRGBO(136, 14, 79, 1),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index
                    ? const Color.fromRGBO(236, 64, 122, 1)
                    : const Color.fromRGBO(136, 14, 79, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromRGBO(252, 228, 236, 1),
      shape: const CircularNotchedRectangle(),
      notchMargin: 20,
      child: Container(
        height: 80.0,
        padding: const EdgeInsets.symmetric(horizontal: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.photo_library,
                label: 'Gallery',
                index: 1,
              ),
            ),
            const SizedBox(width: 90),
            Expanded(
              child: _buildNavItem(
                icon: Icons.history,
                label: 'Routine',
                index: 2,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
