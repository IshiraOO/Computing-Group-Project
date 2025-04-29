import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' show atan2, cos, sin, sqrt, pi;

import '../models/first_aid_instruction.dart';
import '../models/illness.dart';
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../models/medical_facility.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  // Check if user is already signed in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // First Aid Instructions
  Future<List<FirstAidInstruction>> getFirstAidInstructions() async {
    try {
      final snapshot = await _firestore.collection('firstAidInstructions').get();
      return snapshot.docs
          .map((doc) => FirstAidInstruction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting first aid instructions: $e');
      return [];
    }
  }

  Future<FirstAidInstruction?> getFirstAidInstructionById(String id) async {
    try {
      final doc = await _firestore.collection('firstAidInstructions').doc(id).get();
      if (doc.exists) {
        return FirstAidInstruction.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting first aid instruction by ID: $e');
      return null;
    }
  }

  // Emergency Contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final user = getCurrentUser();
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('emergencyContacts')
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('emergencyContacts')
          .doc(contact.id)
          .set(contact.toJson());
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('emergencyContacts')
          .doc(contact.id)
          .update(contact.toJson());
    } catch (e) {
      print('Error updating emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContact(String id) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('emergencyContacts')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  // Medical Facilities
  Future<List<MedicalFacility>> getNearbyMedicalFacilities(
    double latitude,
    double longitude, {
    int radius = 5000, // Default 5km radius
  }) async {
    try {
      // In a real app, this would use Firestore GeoPoint queries or a specialized
      // geolocation service like Firebase Extensions for Geolocation

      // For now, we'll fetch all facilities and filter them client-side
      final snapshot = await _firestore.collection('medicalFacilities').get();

      final facilities = snapshot.docs
          .map((doc) => MedicalFacility.fromJson(doc.data()))
          .toList();

      // Calculate distance for each facility
      List<MedicalFacility> facilitiesWithDistance = [];

      for (var facility in facilities) {
        double distance;
        try {
          // Try to use Geolocator first
          distance = Geolocator.distanceBetween(
            latitude,
            longitude,
            facility.latitude,
            facility.longitude,
          );
        } catch (e) {
          // Fallback to a simple approximation if Geolocator fails
          print('Error using Geolocator, falling back to approximation: $e');
          distance = _approximateDistance(
            latitude,
            longitude,
            facility.latitude,
            facility.longitude,
          );
        }

        // Add the facility with calculated distance
        facilitiesWithDistance.add(MedicalFacility(
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
        ));
      }

      // Filter facilities within the specified radius
      final nearbyFacilities = facilitiesWithDistance
          .where((facility) => facility.distanceInMeters <= radius)
          .toList();

      // Sort by distance
      nearbyFacilities.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

      return nearbyFacilities;
    } catch (e) {
      print('Error getting nearby medical facilities: $e');
      return [];
    }
  }

  // Simple approximation of distance using the Haversine formula
  // This is a fallback method if Geolocator fails
  double _approximateDistance(
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

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }


  // User Profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('userProfiles').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Illness Database
  Future<List<Illness>> getIllnesses() async {
    try {
      final snapshot = await _firestore.collection('illnesses').get();
      return snapshot.docs
          .map((doc) => Illness.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting illnesses: $e');
      return [];
    }
  }

  Future<Illness?> getIllnessById(String id) async {
    try {
      final doc = await _firestore.collection('illnesses').doc(id).get();
      if (doc.exists) {
        return Illness.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting illness: $e');
      return null;
    }
  }

  Future<void> saveUserProfileById(String userId, UserProfile profile) async {
    try {
      await _firestore.collection('userProfiles').doc(userId).set(profile.toJson());
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Emergency Contacts by User ID
  Future<List<EmergencyContact>> getEmergencyContactsById(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('emergencyContacts')
          .get();
      return snapshot.docs
          .map((doc) => EmergencyContact.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  Future<void> saveEmergencyContactById(String userId, EmergencyContact contact) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('emergencyContacts')
          .doc(contact.id)
          .set(contact.toJson());
    } catch (e) {
      print('Error saving emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContactById(String userId, String contactId) async {
    try {
      await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('emergencyContacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      print('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  // Medical Facilities
  Future<List<MedicalFacility>> getMedicalFacilities() async {
    try {
      final snapshot = await _firestore.collection('medicalFacilities').get();
      return snapshot.docs
          .map((doc) => MedicalFacility.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting medical facilities: $e');
      return [];
    }
  }
}