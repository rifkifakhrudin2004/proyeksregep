import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class FaceDetectorService {
  final FaceDetector _faceDetector;
  final bool _isFrontCamera;

  FaceDetectorService({required bool isFrontCamera}) : 
    _isFrontCamera = isFrontCamera,
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        // Mengatur mode performance berdasarkan kamera
        performanceMode: isFrontCamera 
            ? FaceDetectorMode.accurate 
            : FaceDetectorMode.fast,
        // Menyesuaikan minimum confidence untuk deteksi
        minFaceSize: isFrontCamera ? 0.15 : 0.2,
      )
    );

  Future<List<Face>> detectFaces(CameraImage image) async {
    try {
      final inputImage = await _getInputImage(image);
      final faces = await _faceDetector.processImage(inputImage);
      
      // Filter hasil deteksi berdasarkan confidence score
      if (!_isFrontCamera) {
        return faces.where((face) {
          // Hanya mengembalikan wajah dengan confidence tinggi untuk kamera belakang
          final landmarks = face.landmarks;
          final hasGoodLandmarks = landmarks.length >= 3; // minimal memiliki 3 landmark
          final hasGoodSize = face.boundingBox.width > 50 && face.boundingBox.height > 50;
          
          return hasGoodLandmarks && hasGoodSize;
        }).toList();
      }
      
      return faces;
    } catch (e) {
      print('Error during face detection: $e');
      return [];
    }
  }

  Future<InputImage> _getInputImage(CameraImage image) async {
    final allBytes = <int>[];
    for (final Plane plane in image.planes) {
      allBytes.addAll(plane.bytes);
    }
    final bytes = Uint8List.fromList(allBytes);

    // Menyesuaikan rotasi berdasarkan tipe kamera
    final rotation = _isFrontCamera 
        ? InputImageRotation.rotation270deg 
        : InputImageRotation.rotation90deg;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  // Menambahkan method untuk mengecek kualitas deteksi
  bool isGoodDetection(Face face) {
    if (_isFrontCamera) return true; // Selalu return true untuk kamera depan
    
    // Untuk kamera belakang, cek beberapa parameter tambahan
    final boundingBox = face.boundingBox;
    final width = boundingBox.width;
    final height = boundingBox.height;
    
    // Minimal ukuran wajah yang terdeteksi
    final minSize = 100.0;
    // Rasio aspek wajah yang normal (sekitar 1:1.5)
    final aspectRatio = height / width;
    final goodAspectRatio = aspectRatio >= 1.0 && aspectRatio <= 2.0;
    
    return width >= minSize && height >= minSize && goodAspectRatio;
  }

  void close() {
    _faceDetector.close();
  }
}