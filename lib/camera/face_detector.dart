import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';

Future<List<Face>> detectFaces(CameraImage image) async {
  final faceDetector = GoogleMlKit.vision.faceDetector();
  
  // Buat metadata untuk gambar
  final metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: InputImageRotation.rotation0deg, // Sesuaikan dengan orientasi kamera
    format: InputImageFormat.nv21, // Langsung set format gambar ke NV21
    bytesPerRow: image.planes[0].bytesPerRow, // Set bytesPerRow sesuai dengan image
  );

  // Gunakan metadata dalam InputImage
  final inputImage = InputImage.fromBytes(
    bytes: image.planes[0].bytes, // Menggunakan byte dari plane pertama
    metadata: metadata, // Masukkan metadata yang sudah ditetapkan
  );

  // Deteksi wajah
  final List<Face> faces = await faceDetector.processImage(inputImage);
  faceDetector.close();
  
  return faces;
}
