import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Import the CameraScreen
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _address = 'Press button to get address';

  // Function to check and request location permission
  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      // If permission is already granted, get the location
      _getLocation();
    } else if (status.isDenied) {
      // If permission is denied, request permission
      PermissionStatus newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        _getLocation(); // Fetch location after permission is granted
      } else {
        // Show message if permission is still denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission is required.")),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // If the permission is permanently denied, open settings
      openAppSettings();
    }
  }

  // Function to get the location and reverse geocode it
  Future<void> _getLocation() async {
    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Use Geocoding to get the address from latitude and longitude
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      // Set the first address from the placemarks list
      _address = '${placemarks.first.street}, '
          '${placemarks.first.locality}, '
          '${placemarks.first.administrativeArea}, '
          '${placemarks.first.country}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the CameraScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              child: const Text("Open Camera"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkLocationPermission, // Check location permission
              child: const Text("Get Location"),
            ),
            const SizedBox(height: 20),
            Text(
              _address, // Display the address
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
