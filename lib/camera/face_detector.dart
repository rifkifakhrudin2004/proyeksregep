import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
Future<List<Face>> detectFaces(CameraImage image) async {
  final faceDetector = GoogleMlKit.vision.faceDetector();
  try {
    final inputImage = await _getInputImage(image);
    return await faceDetector.processImage(inputImage);
  } catch (e) {
    print('Error during face detection: $e');
    return [];
  } finally {
    faceDetector.close();
  }
}

Future<InputImage> _getInputImage(CameraImage image) async {
  // Menggabungkan data dari setiap plane (YUV420) menjadi satu buffer byte
  final allBytes = <int>[];
  for (final Plane plane in image.planes) {
    allBytes.addAll(plane.bytes);
  }
  final bytes = Uint8List.fromList(allBytes);
  // Metadata untuk input image
  final metadata = InputImageMetadata(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: InputImageRotation.rotation90deg,
    format: InputImageFormat.yuv420,
    bytesPerRow: image.planes[0].bytesPerRow,
  );

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: metadata,
  );
}
