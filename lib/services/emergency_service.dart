import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_contact.dart';
import 'location_service.dart';

class EmergencyService {
  // Send SMS to emergency contacts
  static Future<bool> sendEmergencySMS(List<EmergencyContact> contacts, String message) async {
    try {
      // Get current location
      Position position = await LocationService.getCurrentPosition();
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create message with location
      String fullMessage = "$message\n\nCurrent Location: $address\n\nGoogle Maps Link: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Send SMS to each contact
      for (var contact in contacts) {
        if (contact.notifyInEmergency) {
          final Uri smsUri = Uri(
            scheme: 'sms',
            path: contact.phoneNumber,
            queryParameters: {'body': fullMessage},
          );

          await launchUrl(smsUri);
        }
      }

      return true;
    } catch (e) {
      print('Error sending emergency SMS: $e');
      return false;
    }
  }

  // Make emergency call
  static Future<bool> makeEmergencyCall(String phoneNumber) async {
    try {
      final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
      return await launchUrl(callUri);
    } catch (e) {
      print('Error making emergency call: $e');
      return false;
    }
  }

  // Share location with contacts
  static Future<void> shareLocation() async {
    try {
      // Get current location
      Position position = await LocationService.getCurrentPosition();
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Create message with location
      String message = "I need help! My current location is: $address\n\nGoogle Maps Link: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Share via platform share dialog
      await Share.share(message, subject: 'Emergency: I Need Help!');
    } catch (e) {
      print('Error sharing location: $e');
    }
  }

  // Get emergency services numbers by country
  static Map<String, String> getEmergencyNumbers(String countryCode) {
    // Default to US numbers
    Map<String, String> emergencyNumbers = {
      'police': '911',
      'ambulance': '911',
      'fire': '911',
    };

    // Add country-specific emergency numbers
    switch (countryCode.toUpperCase()) {
      case 'UK':
        emergencyNumbers = {
          'police': '999',
          'ambulance': '999',
          'fire': '999',
        };
        break;
      case 'AU':
        emergencyNumbers = {
          'police': '000',
          'ambulance': '000',
          'fire': '000',
        };
        break;
      // Add more countries as needed
    }

    return emergencyNumbers;
  }
}