import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:proyeksregep/camera/face_painter.dart';

class CameraScreenBody extends StatelessWidget {
  final CameraController? controller;
  final List<Face> faces;
  final bool isFaceDetected;
  final bool showMultipleFacesWarning;
  final VoidCallback onCapturePressed;
  final VoidCallback onSwitchCamera;
  final VoidCallback onOpenGallery;
  final AnimationController animationController;
  final Animation<double> animation;

  const CameraScreenBody({
    Key? key,
    required this.controller,
    required this.faces,
    required this.isFaceDetected,
    required this.showMultipleFacesWarning,
    required this.onCapturePressed,
    required this.onSwitchCamera,
    required this.onOpenGallery,
    required this.animationController,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(child: CameraPreview(controller!)),
        
        // Face Detection Overlay
        CustomPaint(
          painter: FacePainter(faces),
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          child: Container(),
        ),

        // Center Detection Rectangle
        Center(
          child: Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
              border: Border.all(
                color: showMultipleFacesWarning
                    ? Colors.yellow
                    : (isFaceDetected ? Colors.green : Colors.redAccent),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        // Face Detection Status Indicator
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: showMultipleFacesWarning
                    ? Colors.yellow
                    : (isFaceDetected ? Colors.green : Colors.redAccent),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                showMultipleFacesWarning
                    ? "Terdeteksi Lebih dari 1 Wajah"
                    : (isFaceDetected
                        ? "Wajah Terdeteksi"
                        : "Posisikan Wajah Anda"),
                style: TextStyle(
                  color: showMultipleFacesWarning ? Colors.black : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Camera Capture Button
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 2 - 40,
          child: ScaleTransition(
            scale: animation,
            child: GestureDetector(
              onTapDown: (_) {
                animationController.forward();
              },
              onTapUp: (_) {
                animationController.reverse();
                if (isFaceDetected && !showMultipleFacesWarning) {
                  onCapturePressed();
                }
              },
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(20),
                  backgroundColor:
                      (isFaceDetected && !showMultipleFacesWarning)
                          ? const Color.fromRGBO(252, 150, 243, 1)
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

        // Camera Switch Button
        Positioned(
          bottom: 20,
          left: 20,
          child: IconButton(
            icon: Icon(Icons.switch_camera,
                color: const Color.fromRGBO(136, 14, 79, 1), size: 30),
            onPressed: onSwitchCamera,
          ),
        ),

        // Gallery Selection Button
        Positioned(
          bottom: 20,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.photo,
                color: Color.fromRGBO(136, 14, 79, 1), size: 30),
            onPressed: onOpenGallery,
          ),
        ),
      ],
    );
  }
}