import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'models/ImagesData.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';
import 'pages/storage_page.dart';
import 'pages/landing_page.dart'; // Import LandingPage
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<ImageData> imageList = []; // Daftar untuk menyimpan data gambar

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Register App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Set landing sebagai route awal
      routes: {
        '/': (context) => LandingPage(), // Halaman awal
        '/login': (context) => LoginScreen(onLoginSuccess: () {
              // Jika login berhasil, alihkan ke home
              Navigator.pushReplacementNamed(context, '/home');
            }),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
        '/camera': (context) => CameraPage(imageList: imageList), // Mengirimkan imageList
        '/storage': (context) => StoragePage(imageList: imageList), // Mengirimkan imageList
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
