import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  final Function(LatLng) onLocationPicked; // Callback to send the location back

  LocationPickerScreen({required this.onLocationPicked});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _getUserLocation();
    _startLocationListener();
  }

  void _startLocationListener() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Check location every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        currentPosition = position;
      });

      // Check if user is within radius of selected location
      if (selectedLocation != null) {
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          selectedLocation!.latitude,
          selectedLocation!.longitude,
        );

        if (distance <= 100) {
          // 100 meters radius
          _sendNotification("You have a task at this location.");
        }
      }
    });
  }

  // Initialize local notifications
  void _initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var android = const AndroidInitializationSettings('godo');
    var initializationSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _getUserLocation() async {
    PermissionStatus permissionStatus =
        await Permission.locationAlways.request();

    if (permissionStatus.isGranted || permissionStatus.isLimited) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = position;
      });
    } else {
      print("Location permission denied.");
    }
  }

  // Method to handle map taps
  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
    // Move the camera to the selected location
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  // Action when the user confirms the selected location
  void _confirmLocation() {
    if (selectedLocation != null) {
      // Send the selected location back to the previous screen
      widget.onLocationPicked(selectedLocation!);
      // Optionally, show a notification after location is selected
      _sendNotification(
          "Location Confirmed: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}");
      Navigator.pop(context);
    } else {
      // Show a message if no location was selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location first.'),
          duration: Duration(seconds: 2),
          
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      );
    }
  }

  // Show a local notification
  Future<void> _sendNotification(String message) async {
    var androidDetails = const AndroidNotificationDetails(
        'location_channel_id', 'Location Reminders',
        importance: Importance.high, priority: Priority.high, icon: 'godo');

    var notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Location Reminder',
      message,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: currentPosition != null
                    ? LatLng(
                        currentPosition!.latitude, currentPosition!.longitude)
                    : const LatLng(
                        37.7749, -122.4194), // Default to San Francisco
                zoom: 12,
              ),
              onTap: _onMapTapped, // Handle map tap
              markers: selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: selectedLocation!,
                        infoWindow:
                            const InfoWindow(title: 'Selected Location'),
                      )
                    }
                  : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _confirmLocation, // Trigger the confirm action
              child: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
