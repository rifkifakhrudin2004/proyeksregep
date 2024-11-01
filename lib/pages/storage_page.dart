import 'package:flutter/material.dart';
import 'dart:io'; // Tambahkan ini untuk menggunakan File
import 'package:proyeksregep/models/ImagesData.dart';


class StoragePage extends StatelessWidget {
  final List<ImageData> imageList; // Menerima daftar gambar dari konstruktor

  StoragePage({Key? key, required this.imageList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeri'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // Warna AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            final imageData = imageList[index];
            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Sudut bulat untuk kartu
              ),
              elevation: 5, // Menambahkan bayangan pada kartu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)), // Sudut bulat pada gambar
                    child: Image.file(
                      File(imageData.imagePath),
                      fit: BoxFit.contain, // Menggunakan contain agar gambar tidak terpotong
                      height: 200, // Tinggi gambar
                      width: double.infinity, // Lebar gambar mengikuti lebar kartu
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usia: ${imageData.usia}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Gaya teks
                        ),
                        SizedBox(height: 8), // Jarak antar teks
                        Text(
                          'Jenis Kulit: ${imageData.jenisKulit}',
                          style: TextStyle(fontSize: 16), // Gaya teks
                        ),
                        SizedBox(height: 8), // Jarak antar teks
                        Text(
                          'Kandungan: ${imageData.kandungan}',
                          style: TextStyle(fontSize: 16), // Gaya teks
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}