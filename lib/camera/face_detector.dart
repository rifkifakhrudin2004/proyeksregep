import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorService() : _faceDetector = GoogleMlKit.vision.faceDetector();

  Future<List<Face>> detectFaces(CameraImage image) async {
    try {
      final inputImage = await _getInputImage(image);
      return await _faceDetector.processImage(inputImage);
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

    // Ubah rotasi jika diperlukan
    final rotation = InputImageRotation.rotation90deg; // Sesuaikan dengan kebutuhan

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation270deg,
      format: InputImageFormat.yuv420,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  void close() {
    _faceDetector.close();
  }
}