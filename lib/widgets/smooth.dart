import 'package:flutter/material.dart';
import 'package:proyeksregep/pages/home_page.dart';
import 'package:proyeksregep/pages/storage_page.dart';
import 'package:proyeksregep/pages/profile_page.dart';
import 'package:proyeksregep/pages/routinelist_page.dart';
class SmoothNavigationPage extends StatefulWidget {
  final int initialIndex;

  const SmoothNavigationPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _SmoothNavigationPageState createState() => _SmoothNavigationPageState();
}

class _SmoothNavigationPageState extends State<SmoothNavigationPage> {
  late int _currentIndex;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set initial index
  }

  final List<Widget> _pages = [
    HomePage(),
    StoragePage(),
    SkincareRoutineListPage(),
    ProfilePage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
    );
  }
}
