import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'face_painter.dart';
import 'face_detector.dart';
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
  bool isDetectingFaces = false;
  bool isFaceDetected = false;

  late FaceDetectorService _faceDetectorService;

  @override
  void initState() {
    super.initState();
    _faceDetectorService = FaceDetectorService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![isFrontCamera ? 1 : 0],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
      enableAudio: false,
    );
    try {
      await _controller?.initialize();
      if (!mounted) return;

      _controller?.startImageStream((CameraImage image) {
        if (!isDetectingFaces) {
          isDetectingFaces = true;
          _processCameraImage(image).then((_) {
            isDetectingFaces = false;
          });
        }
      });

      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final List<Face> detectedFaces = await _faceDetectorService.detectFaces(image);
      if (mounted) {
        setState(() {
          faces = detectedFaces;
          //perbarui status deteksi wajah
          isFaceDetected = detectedFaces.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile file = await _controller!.takePicture();
        setState(() {
          imageFile = file;
        });
        print('Gambar disimpan di: ${file.path}');
        
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String filePath = 'user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        File imageFile = File(file.path);

        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        print('Gambar berhasil diupload ke: $filePath');

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
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _switchCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      _initializeCamera();
    });
  }

  void _openGallery() {
    // Implementasi untuk membuka galeri
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectorService.close(); // Tutup layanan saat tidak lagi diperlukan
    _controller?.dispose(); // Tutup controller kamera
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Ageskin"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Membuat CameraPreview memenuhi seluruh layar
          Positioned.fill(child: CameraPreview(_controller!)),
          CustomPaint(
            painter: FacePainter(faces),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            child: Container(),
          ),
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle, // Change the shape to rectangle
                border: Border.all(
                  color: isFaceDetected ? Colors.green : Colors.redAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15), // Use a smaller radius
              ),
            ),
          ),

          // Tombol switch camera di kiri bawah
          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera, color: Colors.white, size: 30),
              onPressed: _switchCamera,
            ),
          ),
          // Tombol capture di tengah bawah
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              onPressed: _captureImage,
              child: Icon(Icons.camera_alt, size: 35),
              backgroundColor: Colors.blue,
              splashColor: Colors.greenAccent,
            ),
          ),
          // Tombol galeri di kanan bawah
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.photo, color: Colors.white, size: 30),
              onPressed: _openGallery,
            ),
          ),
        ],
      ),
    );
  }
}
