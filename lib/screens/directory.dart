import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DentistListScreen extends StatefulWidget {
  const DentistListScreen({super.key});

  @override
  State<DentistListScreen> createState() => _DentistListScreenState();
}

class _DentistListScreenState extends State<DentistListScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  LatLng? _currentPosition;

  final String _apiKey = 'AIzaSyDg2XlEGqoJm06pEh-idT_3d8ovScaJ7to';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    // ignore: deprecated_member_use
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = userLatLng;
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLatLng,
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });

    _getNearbyDentists(userLatLng);
  }

  Future<void> _getNearbyDentists(LatLng location) async {
    const int radius = 2000;
    const String keyword = 'dentist';

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&keyword=$keyword&type=dentist&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      final dentistMarkers = results.map((place) {
        final loc = place['geometry']['location'];
        return Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['vicinity'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      });

      setState(() {
        _markers.addAll(dentistMarkers);
      });
    } else {
      // ignore: avoid_print
      print("Error al obtener dentistas: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        title: const Text(
          'Dentistas Cercanos',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                buildingsEnabled: false,
                trafficEnabled: false,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: const Color(0xFF6C63FF),
        tooltip: 'Actualizar ubicación',
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

