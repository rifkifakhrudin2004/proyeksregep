import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;

  FacePainter(this.faces) {
    print('FacePainter created with ${faces.length} faces'); // Debug log
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = faces.isNotEmpty ? Colors.green : const Color.fromARGB(255, 255, 0, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    print('Painting with ${faces.length} faces, color: ${faces.isNotEmpty ? "green" : "blue"}'); // Debug log

    // Menghapus bagian yang menggambar kotak hijau di belakang frame oval
    /*
    for (Face face in faces) {
      print('Drawing face at: ${face.boundingBox}'); // Debug log
      canvas.drawRect(face.boundingBox, paint);
    }
    */
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
