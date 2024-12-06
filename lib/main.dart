import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

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
  TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddress(); // Load the stored address when the app starts
  }

  // Function to load stored address from SharedPreferences
  Future<void> _loadAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedAddress = prefs.getString('address');
    if (storedAddress != null) {
      setState(() {
        _address = storedAddress;
      });
    }
  }

  // Function to check and request location permission
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      _getLocation();
    } else if (status.isDenied) {
      var result = await Permission.location.request();
      if (result.isGranted) {
        _getLocation();
      } else if (result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Location permission is permanently denied. Please enable it in settings."),
          ),
        );
        openAppSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission is required.")),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Location permission is permanently denied. Please enable it in settings."),
        ),
      );
      openAppSettings();
    }
  }

  // Function to get the location and reverse geocode it
  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _address = '${placemarks.first.street}, '
          '${placemarks.first.locality}, '
          '${placemarks.first.administrativeArea}, '
          '${placemarks.first.country}';
    });

    // Save the address in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('address', _address);
  }

  // Function to save a new address to SharedPreferences
  Future<void> _saveNewAddress() async {
    String newAddress = _addressController.text;
    if (newAddress.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('address', newAddress);
      setState(() {
        _address = newAddress;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address saved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid address.")),
      );
    }
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
                // You can navigate to the camera screen as before
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen()));
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
              _address, // Display the current address
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Enter New Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveNewAddress, // Save new address to SharedPreferences
              child: const Text("Save New Address"),
            ),
          ],
        ),
      ),
    );
  }
}
