import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Mulai animasi fade-in setelah sedikit delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
    // Navigasi ke halaman LandingPage setelah durasi tertentu
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1), 
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2), // Durasi animasi fade-in
          child: ClipOval(
            child: Image.asset(
              'assets/login.jpg',
              width: 150,
              height: 150,
              fit: BoxFit.cover, // Agar gambar memenuhi bentuk bulat
            ),
          ),
        ),
      ),
    );
  }
}
