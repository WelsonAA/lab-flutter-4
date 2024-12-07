import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageCaptureScreen(),
    );
  }
}

class ImageCaptureScreen extends StatefulWidget {
  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('saved_image');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  // Callback function to handle image captured from CameraScreen
  void _handleImageCaptured(File image) async {
    setState(() {
      _imageFile = image;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_image', image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturing Images'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [SizedBox(width: 150,height: 150),
          Center(
            child: Container(
              width: 380,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color to white
                border: Border.all(
                  color: Colors.black, // Black border color
                  width: 2, // Border width
                ),
                borderRadius: BorderRadius.circular(15), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Subtle shadow
                    spreadRadius: 2, // Spread of the shadow
                    blurRadius: 5, // Blur effect for the shadow
                    offset: const Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15), // Match border radius for rounded corners
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              )
                  : const Center(child: Text('Image should appear here')),
            ),
          ),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(
                        onImageCaptured: _handleImageCaptured, // Pass callback to CameraScreen
                      ),
                    ),
                  );
                },
                child: const Text('Capture Image'),
              ),
              ElevatedButton(
                onPressed: () {

                },
                child: const Text('Select Image'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
