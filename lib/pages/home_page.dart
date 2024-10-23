import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar perangkat
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // Mendefinisikan ukuran tombol yang konsisten
    var buttonWidth = screenWidth * 0.6;
    var buttonHeight = screenHeight * 0.08;

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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05), // Padding dinamis berdasarkan lebar layar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selamat datang di Aplikasi Deteksi Wajah',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Ukuran teks yang dinamis
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.05), // Jarak antar teks dan tombol dinamis
                      // Tombol Buka Kamera dengan ukuran yang konsisten
                      SizedBox(
                        width: buttonWidth, // Lebar tombol tetap
                        height: buttonHeight, // Tinggi tombol tetap
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/camera');
                          },
                          icon: Icon(Icons.camera_alt, size: screenWidth * 0.05), // Ukuran ikon dinamis
                          label: Text('Buka Kamera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.045, // Ukuran teks tombol yang dinamis
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03), // Jarak antar tombol dinamis
                      // Tombol Gallery dengan ukuran yang konsisten
                      SizedBox(
                        width: buttonWidth, // Lebar tombol tetap
                        height: buttonHeight, // Tinggi tombol tetap
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/storage');
                          },
                          icon: Icon(Icons.storage, size: screenWidth * 0.05), // Ukuran ikon dinamis
                          label: Text('Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.045, // Ukuran teks tombol yang dinamis
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03), // Jarak antar tombol dinamis
                      // Tombol Profile
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          icon: Icon(Icons.person, size: screenWidth * 0.05),
                          label: Text('Profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03), // Jarak antar tombol dinamis
                      // Tombol Logout
                      SizedBox(
                        width: buttonWidth,
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          icon: Icon(Icons.logout, size: screenWidth * 0.05),
                          label: Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Ubah warna tombol logout
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02), // Jarak dari bawah layar dinamis
              child: Text(
                'Kelompok 2',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
