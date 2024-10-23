import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:proyeksregep/models/ImagesData.dart';
import 'package:proyeksregep/pages/storage_page.dart';

class CameraPage extends StatefulWidget {
  final List<ImageData> imageList; // Menerima imageList dari constructor

  CameraPage({Key? key, required this.imageList}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false; // Menandai status pengambilan gambar

  // Daftar data dummy
  List<Map<String, String>> dummyData = [
    {'usia': '10', 'jenisKulit': 'kering', 'kandungan': 'Minyak Zaitun, Aloe Vera'},
    {'usia': '25', 'jenisKulit': 'berminyak', 'kandungan': 'Asam Salisilat, Tea Tree Oil'},
    {'usia': '40', 'jenisKulit': 'sensitif', 'kandungan': 'Ekstrak Chamomile, Hyaluronic Acid'},
    {'usia': '30', 'jenisKulit': 'kering', 'kandungan': 'Minyak Almond, Shea Butter'},
    {'usia': '45', 'jenisKulit': 'berminyak', 'kandungan': 'Zinc, Niacinamide'},
    {'usia': '18', 'jenisKulit': 'sensitif', 'kandungan': 'Ekstrak Lidah Buaya, Glycerin'},
    {'usia': '33', 'jenisKulit': 'kering', 'kandungan': 'Squalane, Vitamin E'},
    {'usia': '15', 'jenisKulit': 'berminyak', 'kandungan': 'Asam Glycolic, BHA'},
    {'usia': '28', 'jenisKulit': 'sensitif', 'kandungan': 'Centella Asiatica, Allantoin'},
    {'usia': '35', 'jenisKulit': 'kering', 'kandungan': 'Coconut Oil, Ceramide'},
    {'usia': '22', 'jenisKulit': 'berminyak', 'kandungan': 'Bentonite Clay, Sulfur'},
    {'usia': '50', 'jenisKulit': 'sensitif', 'kandungan': 'Panthenol, Madecassoside'},
    {'usia': '38', 'jenisKulit': 'kering', 'kandungan': 'Rosehip Oil, Jojoba Oil'},
    {'usia': '27', 'jenisKulit': 'berminyak', 'kandungan': 'Charcoal, Kaolin'},
    {'usia': '16', 'jenisKulit': 'sensitif', 'kandungan': 'Calendula Extract, Chamomile'},
    {'usia': '42', 'jenisKulit': 'kering', 'kandungan': 'Avocado Oil, Vitamin C'},

  ];

  Future<void> _getImage(BuildContext context) async {
    if (_isPickingImage) return; // Cek jika sudah ada sesi pengambilan gambar
    setState(() {
      _isPickingImage = true; // Menandai sesi pengambilan gambar aktif
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // Pilih data dummy secara acak
        final randomIndex = Random().nextInt(dummyData.length);
        final selectedData = dummyData[randomIndex];

        // Menambahkan data gambar dan deskripsi yang dipilih secara acak
        ImageData imageData = ImageData(
          imagePath: image.path,
          usia: selectedData['usia']!,
          jenisKulit: selectedData['jenisKulit']!,
          kandungan: selectedData['kandungan']!,
        );

        // Menyimpan data dummy ke dalam list
        widget.imageList.add(imageData);

        // Tampilkan gambar dari kamera dengan informasi dummy
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(image.path)), // Menampilkan gambar yang diambil
                SizedBox(height: 10),
                Text(
                  'Usia: ${imageData.usia}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Jenis Kulit: ${imageData.jenisKulit}',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'Kandungan: ${imageData.kandungan}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isPickingImage = false; // Reset status setelah dialog ditutup
                      });
                    },
                    child: Text('Tutup'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pushNamed(context, '/storage',
                          arguments: widget.imageList); // Navigasi ke StoragePage
                    },
                    child: Text('Lihat Gambar'),
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isPickingImage = false; // Reset status jika tidak ada gambar
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isPickingImage = false; // Reset status jika terjadi error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kamera'),
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
        child: Center(
          child: ElevatedButton(
            onPressed: () => _getImage(context),
            child: Text('Ambil Gambar', style: TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: Colors.white, // Warna latar belakang tombol
              foregroundColor: Colors.blueAccent, // Warna teks tombol
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Gaya teks tombol
            ),
          ),
        ),
),
    );
  }
}
