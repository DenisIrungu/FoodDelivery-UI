import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Request location permission and get current position
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // If everything is good, get the position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Reverse geocode: convert coordinates into address
  static Future<String> getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final addressParts = [
          place.subLocality, // e.g., Kanduyi
          place.locality, // e.g., Bungoma
          place.administrativeArea, // optional: e.g., Western
        ].where((part) => part != null && part.isNotEmpty).toList();

        return addressParts.join(', ');
      }
    } catch (e) {
      debugPrint("Error in reverse geocoding: $e");
    }
    return 'Unknown location';
  }
}
