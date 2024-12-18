import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'face_painter.dart';
import 'face_detector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../pages/ReviewPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyeksregep/services/predict_service.dart';
import 'package:proyeksregep/widgets/camera/bodycamera_widget.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  List<Face> faces = [];
  bool isFrontCamera = true;
  XFile? imageFile;
  bool isDetectingFaces = false;
  bool isFaceDetected = false;
  bool _showMultipleFacesWarning = false;
  String? predictedClass;
  String? persentase;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late FaceDetectorService _faceDetectorService;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Durasi animasi
    );
    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _faceDetectorService = FaceDetectorService(isFrontCamera: isFrontCamera);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      // Validate camera list
      if (cameras == null || cameras!.isEmpty) {
        _showAlertDialog('Camera Error', 'No cameras available');
        return;
      }

      // Safely select camera index
      int cameraIndex = isFrontCamera ? (cameras!.length > 1 ? 1 : 0) : 0;

      _controller = CameraController(
        cameras![cameraIndex],
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.bgra8888,
        enableAudio: false,
      );

      await _controller?.initialize();

      if (!mounted) return;

      if (_controller != null) {
        _controller?.startImageStream((CameraImage image) async {
          if (!isDetectingFaces) {
            isDetectingFaces = true;
            await _processCameraImage(image);
            isDetectingFaces = false;
          }
        });
      }

      setState(() {}); // Update UI
    } catch (e) {
      print('Comprehensive camera initialization error: $e');
      _showAlertDialog('Camera Initialization Error',
          'Failed to initialize camera. Please check permissions and try again.');
    }
  }

  void _switchCamera() async {
    try {
      // Safely stop image stream if it's active
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller?.stopImageStream();
      }

      // Add a small delay to ensure stream is completely stopped
      await Future.delayed(Duration(milliseconds: 200));

      // Dispose controller safely with null check
      if (_controller != null) {
        await _controller?.dispose();
      }

      setState(() {
        // Toggle camera
        isFrontCamera = !isFrontCamera;
        faces = []; // Reset detected faces
        isFaceDetected = false;
        _showMultipleFacesWarning = false;
        _controller = null;
      });

      // Close previous face detection service
      _faceDetectorService.close();

      // Recreate face detection service
      _faceDetectorService = FaceDetectorService(isFrontCamera: isFrontCamera);

      // Reinitialize camera
      await _initializeCamera();
    } catch (e) {
      print('Comprehensive error during camera switch: $e');
      _showAlertDialog('Camera Switch Error',
          'Failed to switch camera. Please try again or restart the app.');

      // Optional: Reset to a known good state
      setState(() {
        _controller = null;
        isFrontCamera = !isFrontCamera; // Toggle back
      });

      // Attempt to reinitialize
      await _initializeCamera();
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      final List<Face> detectedFaces =
          await _faceDetectorService.detectFaces(image);

      if (mounted) {
        setState(() {
          faces = detectedFaces;

          // Update face detection logic
          if (isFrontCamera) {
            // Tetap lakukan deteksi wajah tanpa menghentikan kamera
            _showMultipleFacesWarning = (detectedFaces.length > 1);
            isFaceDetected = detectedFaces.length == 1;
          } else {
            // Untuk kamera belakang, tambahkan validasi kualitas deteksi
            _showMultipleFacesWarning = (detectedFaces.length > 1);
            isFaceDetected = detectedFaces.length == 1 &&
                detectedFaces
                    .any((face) => _faceDetectorService.isGoodDetection(face));
          }
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        setState(() {
          isFaceDetected = false;
          _showMultipleFacesWarning = false;
        });
      }
    }
  }
  void _showMultipleFacesAlert() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Peringatan'),
            content: Text('Terdeteksi 2 wajah dalam kamera'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  String _getFileName(XFile file) {
    // Mendapatkan nama file dari path gambar dan membuat nama file yang lebih bersih
    String fileName = file.name; // Nama file asli
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "$timestamp-$fileName"; // Menambahkan timestamp untuk memastikan nama file unik
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        // Tampilkan dialog loading sebelum capture
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang memproses gambar...\nMohon tunggu'),
                ],
              ),
            );
          },
        );

        final XFile file = await _controller!.takePicture();
        setState(() {
          imageFile = file;
        });

        String fileName = _getFileName(file);
        String? filePath = await _uploadImageToFirebase(file, fileName);

        if (filePath != null) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Tutup dialog loading
            Navigator.of(context).pop();
            final result = await ImageProcessingService.sendImageData(
                userId: user.uid, imageFilename: filePath);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewPage(
                  imageFile: file,
                  predictedClass: result['predictedClass'],
                  persentase: result['persentase'],
                  handling: result['handling'],
                  skincare: result['skincare'],
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Pastikan dialog loading ditutup jika terjadi error
        Navigator.of(context).pop();
        print('Error saat mengambil gambar: $e');
      }
    }
  }

  Future<String?> _uploadImageToFirebase(XFile file, String fileName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String filePath = 'user_images/${user.uid}/$fileName';
        File imageFile = File(file.path);

        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        print('Gambar berhasil diupload ke: $filePath');
        return filePath; // Return path after successful upload
      } else {
        print('Pengguna tidak terautentikasi!');
        return null;
      }
    } catch (e) {
      print('Error saat mengupload gambar: $e');
      return null;
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
void _openGallery() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final faceDetector =
          GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.accurate,
      ));
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      try {
        final List<Face> faces = await faceDetector.processImage(inputImage);

        if (faces.isEmpty || faces.length > 1) {
          _showAlertDialog(
              'Validasi Gambar',
              faces.isEmpty
                  ? 'Tidak ada wajah terdeteksi.'
                  : 'Hanya satu wajah yang diperbolehkan dalam gambar.');
          return;
        }
        final firstFace = faces.first;
        if (firstFace.boundingBox.width < 100 ||
            firstFace.boundingBox.height < 100) {
          _showAlertDialog('Validasi Gambar',
              'Wajah terlalu kecil. Pilih gambar dengan wajah yang lebih jelas dan dekat.');
          return;
        }
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang memproses gambar...\nMohon tunggu'),
                ],
              ),
            );
          },
        );
        setState(() {
          imageFile = pickedFile;
        });
        String fileName = _getFileName(pickedFile);
        String? filePath = await _uploadImageToFirebase(pickedFile, fileName);

        if (filePath != null) {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Navigator.of(context).pop();
            final result = await ImageProcessingService.sendImageData(
                userId: user.uid, imageFilename: filePath);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewPage(
                  imageFile: pickedFile,
                  predictedClass: result['predictedClass'],
                  persentase: result['persentase'],
                  handling: result['handling'],
                  skincare: result['skincare'],
                ),
              ),
            );
          }
        }
        await faceDetector.close();
      } catch (e) {
        // Tangani kesalahan deteksi wajah
        print('Error deteksi wajah: $e');
        _showAlertDialog(
            'Error', 'Gagal memvalidasi gambar. Silakan coba lagi.');
      }
    }
  } catch (e) {
    Navigator.of(context).pop();
    print('Error saat memilih gambar dari galeri: $e');
    _showAlertDialog('Error', 'Gagal memilih gambar. Silakan coba lagi.');
  }
}
  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectorService.close();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Camera",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(136, 14, 79, 1),
          )),
      backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ),
    body: CameraScreenBody(
      controller: _controller,
      faces: faces,
      isFaceDetected: isFaceDetected,
      showMultipleFacesWarning: _showMultipleFacesWarning,
      onCapturePressed: _captureImage,
      onSwitchCamera: _switchCamera,
      onOpenGallery: _openGallery,
      animationController: _animationController,
      animation: _animation,
    ),
  );
}
    }