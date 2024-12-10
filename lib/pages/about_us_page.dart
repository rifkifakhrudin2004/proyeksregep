import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Kami',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
            
          ),
        ),
        backgroundColor: Color.fromRGBO(252, 228, 236, 1), // AppBar background color
      ),
      body: Container(
        color: Colors.white, // White background for the body
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Full-width image section with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Rounded corners for the image
                child: Image.asset(
                  'assets/Teamsregep.png', // Add your image here
                  width: MediaQuery.of(context).size.width, // Stretching the image to full width
                  height: 250, // Fixed height for the image
                  fit: BoxFit.cover, // Ensures the image covers the full width and height
                ),
              ),
              SizedBox(height: 30),

              // Title Text
              Text(
                'Tentang Aplikasi Kami',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(136, 14, 79, 1),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Box with text content
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 228, 236, 1), // Box background color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aplikasi ini dibuat oleh kelompok 2 dengan nama tim "Tim Sregep" yang beranggotakan:\n\n'
                      '1. Agung Rizky Kurniawan\n'
                      '2. Ersa Oktavian Ramadhan\n'
                      '3. Masyithah Sophia Damayanti\n'
                      '4. Rifki Fakhrudin\n\n'
                      'Aplikasi ini dibuat sebagai tugas akhir untuk proyek di semester 5. Kami berkomitmen untuk memberikan pengalaman terbaik dan solusi yang inovatif, serta memberikan kemudahan bagi setiap pengguna.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
