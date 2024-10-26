import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'face_painter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  List<Face> faces = [];
  bool isFrontCamera = true;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![isFrontCamera ? 1 : 0],
      ResolutionPreset.high,
    );
    await _controller?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _switchCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      _initializeCamera();
    });
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile file = await _controller!.takePicture();
        setState(() {
          imageFile = file;
        });
        print('Gambar disimpan di: ${file.path}');
        
        // Panggil metode untuk menyimpan gambar ke Firebase Storage
        await _uploadImageToFirebase(file);
      } catch (e) {
        print('Error saat mengambil gambar: $e');
      }
    } else {
      print('Kamera belum diinisialisasi!');
    }
  }

  Future<void> _uploadImageToFirebase(XFile file) async {
    try {
      // Ambil UID pengguna saat ini
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Buat referensi ke lokasi penyimpanan di Firebase Storage
        String filePath = 'user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File imageFile = File(file.path);

        // Upload file ke Firebase Storage
        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        print('Gambar berhasil diupload ke: $filePath');

        // Tampilkan alert dialog setelah berhasil mengupload gambar
        _showAlertDialog('Sukses', 'Gambar berhasil diambil dan diupload!');
      } else {
        print('Pengguna tidak terautentikasi!');
      }
    } catch (e) {
      print('Error saat mengupload gambar: $e');
      _showAlertDialog('Error', 'Gagal mengupload gambar.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          CustomPaint(
            painter: FacePainter(faces),
            child: Container(),
          ),
          Center(
            child: Container(
              width: 250, // Lebar oval
              height: 300, // Tinggi oval
              decoration: BoxDecoration(
                color: Colors
                    .transparent, // Warna latar belakang bisa diubah sesuai kebutuhan
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(
                    200), // Mengatur radius sudut untuk oval
              ),
            ),
          ),

          // Menambahkan Overlay untuk UI yang lebih baik
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera, color: Colors.white, size: 30),
              onPressed: _switchCamera,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
