import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

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
            onPressed: () {
              // Handle taking a photo or other camera actions
            },
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
