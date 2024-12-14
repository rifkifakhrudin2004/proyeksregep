import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'face_painter.dart';
import 'face_detector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/ReviewPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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
    int cameraIndex = isFrontCamera 
        ? (cameras!.length > 1 ? 1 : 0) 
        : 0;

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

// Tambahkan method baru untuk menampilkan alert
  void _showMultipleFacesAlert() {
    // Pastikan tidak menampilkan alert berulang kali
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

            // Navigasi ke ReviewPage dengan status processing
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewPage(
                  imageFile: file,
                ),
              ),
            );

            // Proses ML di background
            await sendImageData(user.uid, filePath);
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

  Future<void> sendImageData(String userId, String imageFilename) async {
    try {
      final fileName = imageFilename.split('/').last;
      final url = Uri.parse('http://192.168.0.102:5000/upload');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'image_filename': imageFilename,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String predictedClass = responseData['prediction']['predicted_class'];
        String persentase =
            responseData['prediction']['predicted_probability'].toString() +
                '%';

        String handling = '';
        String skincare = '';

        if (predictedClass == 'dry') {
          if (double.parse(persentase.replaceAll('%', '')) >= 50) {
            handling = 'Kulit kering berat! Gunakan pelembab super intensif';
            skincare = 'Ceramide Cream, Hyaluronic Acid, Barrier Repair Serum';
          } else if (double.parse(persentase.replaceAll('%', '')) >= 20 &&
              double.parse(persentase.replaceAll('%', '')) < 50) {
            handling = 'Kulit kering sedang! Gunakan pelembab khusus';
            skincare = 'Rich Moisturizer, Niacinamide Serum';
          } else {
            handling = 'Kulit kering ringan! Gunakan pelembab ringan';
            skincare = 'Hydrating Lotion, Gentle Moisturizer';
          }
        } else if (predictedClass == 'oily') {
          if (double.parse(persentase.replaceAll('%', '')) >= 50) {
            handling = 'Kulit sangat berminyak! Kontrol produksi sebum';
            skincare =
                'Salicylic Acid Cleanser, Oil-free Mattifying Moisturizer';
          } else if (double.parse(persentase.replaceAll('%', '')) >= 20 &&
              double.parse(persentase.replaceAll('%', '')) < 50) {
            handling =
                'Kulit berminyak sedang! Gunakan produk pembersih khusus';
            skincare = 'Gentle Foaming Cleanser, Lightweight Gel Moisturizer';
          } else {
            handling = 'Kulit berminyak ringan! Gunakan produk kontrol minyak';
            skincare = 'Mild Cleanser, Water-based Moisturizer';
          }
        } else if (predictedClass == 'normal') {
          handling = 'Kulit normal! Gunakan produk seimbang';
          skincare = 'Gentle Cleanser, Hydrating Lotion';
        }

        // Navigasi ke ReviewPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              imageFile: imageFile!,
              predictedClass: predictedClass,
              persentase: persentase,
              handling: handling,
              skincare: skincare,
            ),
          ),
        );
      } else {
        print('Gagal mengirim data: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (e) {
      print('Error lengkap: $e');
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
      // Pilih gambar dari galeri
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Inisialisasi face detector
        final faceDetector =
            GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
          enableClassification: true,
          minFaceSize: 0.15,
          performanceMode: FaceDetectorMode.accurate,
        ));

        // Baca gambar
        final inputImage = InputImage.fromFilePath(pickedFile.path);

        try {
          // Deteksi wajah
          final List<Face> faces = await faceDetector.processImage(inputImage);

          // Validasi jumlah dan kualitas wajah
          if (faces.isEmpty || faces.length > 1) {
            // Tampilkan alert jika tidak ada wajah atau lebih dari satu wajah
            _showAlertDialog(
                'Validasi Gambar',
                faces.isEmpty
                    ? 'Tidak ada wajah terdeteksi.'
                    : 'Hanya satu wajah yang diperbolehkan dalam gambar.');
            return;
          }

          // Validasi ukuran dan kualitas wajah
          final firstFace = faces.first;
          if (firstFace.boundingBox.width < 100 ||
              firstFace.boundingBox.height < 100) {
            _showAlertDialog('Validasi Gambar',
                'Wajah terlalu kecil. Pilih gambar dengan wajah yang lebih jelas dan dekat.');
            return;
          }

          // Tampilkan dialog loading
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

          // Set state dengan file yang dipilih
          setState(() {
            imageFile = pickedFile;
          });

          // Dapatkan nama file
          String fileName = _getFileName(pickedFile);

          // Upload gambar ke Firebase
          String? filePath = await _uploadImageToFirebase(pickedFile, fileName);

          if (filePath != null) {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // Tutup dialog loading
              Navigator.of(context).pop();

              // Navigasi ke ReviewPage dengan status processing
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewPage(
                    imageFile: pickedFile,
                  ),
                ),
              );

              // Proses ML di background
              await sendImageData(user.uid, filePath);
            }
          }

          // Tutup face detector
          await faceDetector.close();
        } catch (e) {
          // Tangani kesalahan deteksi wajah
          print('Error deteksi wajah: $e');
          _showAlertDialog(
              'Error', 'Gagal memvalidasi gambar. Silakan coba lagi.');
        }
      }
    } catch (e) {
      // Pastikan dialog loading ditutup jika terjadi error
      Navigator.of(context).pop();
      print('Error saat memilih gambar dari galeri: $e');
      _showAlertDialog('Error', 'Gagal memilih gambar. Silakan coba lagi.');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectorService.close(); // Tutup layanan saat tidak lagi diperlukan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Agingskin",
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
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: _showMultipleFacesWarning
                      ? Colors.yellow
                      : (isFaceDetected ? Colors.green : Colors.redAccent),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Wajah Terdeteksi / Posisikan Wajah Anda indicator
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _showMultipleFacesWarning
                      ? Colors.yellow
                      : (isFaceDetected ? Colors.green : Colors.redAccent),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _showMultipleFacesWarning
                      ? "Terdeteksi Lebih dari 1 Wajah"
                      : (isFaceDetected
                          ? "Wajah Terdeteksi"
                          : "Posisikan Wajah Anda"),
                  style: TextStyle(
                    color:
                        _showMultipleFacesWarning ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

// Update center rectangle
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                border: Border.all(
                  color: _showMultipleFacesWarning
                      ? Colors.yellow
                      : (isFaceDetected ? Colors.green : Colors.redAccent),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

// Tombol capture
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: ScaleTransition(
              scale: _animation,
              child: GestureDetector(
                onTapDown: (_) {
                  _animationController.forward();
                },
                onTapUp: (_) async {
                  _animationController.reverse();
                  // Hanya izinkan capture jika hanya 1 wajah yang terdeteksi
                  if (isFaceDetected && !_showMultipleFacesWarning) {
                    await _captureImage();
                  }
                },
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    // Nonaktifkan tombol jika lebih dari 1 wajah
                    backgroundColor:
                        (isFaceDetected && !_showMultipleFacesWarning)
                            ? Colors.blue
                            : Colors.grey,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Color.fromRGBO(136, 14, 79, 1),
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
          if (predictedClass != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Prediksi: $predictedClass',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (persentase != null)
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Probabilitas: $persentase%',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera,
                  color: const Color.fromRGBO(136, 14, 79, 1), size: 30),
              onPressed: _switchCamera,
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: ScaleTransition(
              scale: _animation,
              child: GestureDetector(
                onTapDown: (_) {
                  _animationController
                      .forward(); // Memulai animasi saat tombol ditekan
                },
                onTapUp: (_) async {
                  _animationController
                      .reverse(); // Mengembalikan animasi saat tombol dilepas
                  if (isFaceDetected) {
                    await _captureImage(); // Menangkap gambar
                  }
                },
                child: ElevatedButton(
                  onPressed: null, // GestureDetector menangani interaksi
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: isFaceDetected ? Colors.blue : Colors.grey,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Color.fromRGBO(136, 14, 79, 1),
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.photo,
                  color: Color.fromRGBO(136, 14, 79, 1), size: 30),
              onPressed: _openGallery,
            ),
          ),
        ],
      ),
    );
  }
}
