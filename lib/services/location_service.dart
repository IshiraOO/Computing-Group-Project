import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/medical_facility.dart';

class LocationService {
  // Get current position
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Unable to get address";
    }
  }

  // Calculate distance between two coordinates in meters
  static Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      print('Error calculating distance: $e');
      // Fallback to a simple approximation if Geolocator fails
      return _approximateDistance(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    }
  }

  // Simple approximation of distance using the Haversine formula
  // This is a fallback method if Geolocator fails
  static double _approximateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // in meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = (
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2)
    );

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * (pi / 180);
  }


  // Find nearest medical facilities
  static Future<List<MedicalFacility>> findNearestFacilities(
      List<MedicalFacility> facilities, Position currentPosition, int limit) async {
    // Calculate distance for each facility
    for (int i = 0; i < facilities.length; i++) {
      var facility = facilities[i];
      double distance = await calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        facility.latitude,
        facility.longitude,
      );

      // Update the facility with the calculated distance
      facilities[i] = MedicalFacility(
        id: facility.id,
        name: facility.name,
        address: facility.address,
        latitude: facility.latitude,
        longitude: facility.longitude,
        phoneNumber: facility.phoneNumber,
        website: facility.website,
        services: facility.services,
        facilityType: facility.facilityType,
        isOpen24Hours: facility.isOpen24Hours,
        operatingHours: facility.operatingHours,
        rating: facility.rating,
        distanceInMeters: distance.toInt(),
      );
    }

    // Sort facilities by distance
    facilities.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

    // Return the nearest facilities up to the limit
    return facilities.take(limit).toList();
  }

  // Generate Google Maps URL for navigation
  static String generateMapsUrl(double destLatitude, double destLongitude, String destName) {
    return "https://www.google.com/maps/dir/?api=1&destination=$destLatitude,$destLongitude&destination_place_id=$destName";
  }

  // Generate map markers for facilities
  static Set<Marker> generateMarkers(List<MedicalFacility> facilities, Function(String) onTap) {
    Set<Marker> markers = {};

    for (var facility in facilities) {
      markers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude, facility.longitude),
          infoWindow: InfoWindow(
            title: facility.name,
            snippet: "${facility.facilityType} • ${(facility.distanceInMeters / 1000).toStringAsFixed(1)} km",
            onTap: () => onTap(facility.id),
          ),
        ),
      );
    }

    return markers;
  }
}