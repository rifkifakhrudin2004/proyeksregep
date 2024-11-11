import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/register.dart';
import 'auth/landing_page.dart';
import 'models/ImagesData.dart';
import 'camera/camera_screen.dart';
import 'pages/home_page.dart';
import 'pages/storage_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<ImageData> imageList = []; // Daftar untuk menyimpan data gambar

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Register App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash', // Set SplashScreen sebagai route awal
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => LandingPage(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
        '/camera': (context) => CameraScreen(),
        '/storage': (context) => StoragePage(imageList: imageList),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

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
      backgroundColor: Colors.grey[300], // Background abu-abu
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2), // Durasi animasi fade-in
          child: ClipOval(
            child: Image.asset(
              'assets/Olivia.png',
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
