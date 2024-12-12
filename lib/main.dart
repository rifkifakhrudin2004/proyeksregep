import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/register.dart';
import 'auth/landing_page.dart';
import 'camera/camera_screen.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/routinelist_page.dart';
import 'pages/splashScreen.dart'; // Tambahkan import ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        '/profile': (context) => ProfilePage(),
        '/routine': (context) => SkincareRoutineListPage(),
      },
    );
  }
}
