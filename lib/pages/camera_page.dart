import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Mengambil daftar kamera yang tersedia
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(camera, ResolutionPreset.high);
    // Menginisialisasi controller
    _initializeControllerFuture = _cameraController.initialize();

    // Mulai streaming gambar setelah inisialisasi selesai
    _initializeControllerFuture.then((_) {
      // Start image stream
      _cameraController.startImageStream((CameraImage image) {
        _detectFaces(image);
      });
    });
  }

  Future<void> _detectFaces(CameraImage image) async {
    // Proses gambar untuk mendeteksi wajah
    // Konversi gambar CameraImage ke format yang bisa digunakan oleh detektor
    // Anda perlu menyesuaikan kode ini sesuai kebutuhan
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              CameraPreview(_cameraController),
              // Frame wajah, sesuaikan ukuran dan posisinya
              Positioned(
                left: 50,
                top: 100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
