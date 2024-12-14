import 'package:flutter/material.dart';

class CameraGuideHelper {
  final BuildContext context;

  CameraGuideHelper(this.context);

  void showCameraGuide() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Panduan Pemakaian Kamera',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(136, 14, 79, 1),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: InteractiveViewer(
                  maxScale: 4.0,
                  minScale: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/panduan.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/camera');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(252, 228, 236, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mulai Kamera',
                  style: TextStyle(
                    color: Color.fromRGBO(136, 14, 79, 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
