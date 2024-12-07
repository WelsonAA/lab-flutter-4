import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  final Function(File) onImageCaptured; // Callback to return the image

  const CameraScreen({super.key, required this.onImageCaptured});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Check for camera permission
    var status = await Permission.camera.request();
    if (status.isGranted) {
      // Get available cameras
      _cameras = await availableCameras();
      // Initialize the first camera
      _controller = CameraController(_cameras[0], ResolutionPreset.high);
      await _controller?.initialize();
      setState(() {
        _isCameraReady = true;
      });
    } else {
      // Show an alert if permission is not granted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission is required.")),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null) {
      final XFile file = await _controller!.takePicture();
      widget.onImageCaptured(File(file.path)); // Return the captured image to the parent screen
      Navigator.pop(context); // Return to the previous screen after capturing the image
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Screen"),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          ElevatedButton(
            onPressed: _captureImage,
            child: const Text("Capture"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
