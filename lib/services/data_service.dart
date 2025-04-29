import 'dart:convert';
import 'package:first_aid_health_care/models/emergency_contact.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/first_aid_instruction.dart';
import '../models/illness.dart';
import '../models/medical_facility.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';
import 'location_service.dart';

class DataService {
  final FirebaseService _firebaseService = FirebaseService();

  // Check connectivity
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // First Aid Instructions
  Future<List<FirstAidInstruction>> getFirstAidInstructions() async {
    try {
      // Try to get from Firebase if connected
      if (await isConnected()) {
        final instructions = await _firebaseService.getFirstAidInstructions();
        // Save to local storage for offline access
        await LocalStorageService.saveFirstAidInstructions(instructions);
        return instructions;
      } else {
        // Get from local storage if offline
        return await LocalStorageService.getFirstAidInstructions();
      }
    } catch (e) {
      print('Error getting first aid instructions: $e');
      // Fallback to local storage
      return await LocalStorageService.getFirstAidInstructions();
    }
  }

  Future<FirstAidInstruction?> getFirstAidInstructionById(String id) async {
    try {
      if (await isConnected()) {
        final instruction = await _firebaseService.getFirstAidInstructionById(id);
        return instruction;
      } else {
        return await LocalStorageService.getFirstAidInstructionById(id);
      }
    } catch (e) {
      print('Error getting first aid instruction: $e');
      return await LocalStorageService.getFirstAidInstructionById(id);
    }
  }

  // Illnesses
  Future<List<Illness>> getIllnesses() async {
    try {
      if (await isConnected()) {
        final illnesses = await _firebaseService.getIllnesses();
        // Save to local storage for offline access
        await LocalStorageService.saveIllnesses(illnesses);
        return illnesses;
      } else {
        return await LocalStorageService.getIllnesses();
      }
    } catch (e) {
      print('Error getting illnesses: $e');
      return await LocalStorageService.getIllnesses();
    }
  }

  Future<Illness?> getIllnessById(String id) async {
    try {
      if (await isConnected()) {
        final illness = await _firebaseService.getIllnessById(id);
        return illness;
      } else {
        return await LocalStorageService.getIllnessById(id);
      }
    } catch (e) {
      print('Error getting illness: $e');
      return await LocalStorageService.getIllnessById(id);
    }
  }

  // Emergency Contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      if (await isConnected()) {
        final contacts = await _firebaseService.getEmergencyContacts();
        // Save to local storage for offline access
        await LocalStorageService.saveEmergencyContacts(contacts);
        return contacts;
      } else {
        return await LocalStorageService.getEmergencyContacts();
      }
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return await LocalStorageService.getEmergencyContacts();
    }
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      if (await isConnected()) {
        await _firebaseService.addEmergencyContact(contact);
      }
      // Always save to local storage
      await LocalStorageService.addEmergencyContact(contact);
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    try {
      if (await isConnected()) {
        await _firebaseService.updateEmergencyContact(contact);
      }
      // Always update local storage
      await LocalStorageService.updateEmergencyContact(contact);
    } catch (e) {
      print('Error updating emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContact(String id) async {
    try {
      if (await isConnected()) {
        await _firebaseService.deleteEmergencyContact(id);
      }
      // Always update local storage
      await LocalStorageService.deleteEmergencyContact(id);
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
      if (await isConnected()) {
        final facilities = await _firebaseService.getNearbyMedicalFacilities(
          latitude,
          longitude,
          radius: radius,
        );
        // Save to local storage for offline access
        await LocalStorageService.saveMedicalFacilities(facilities);
        return facilities;
      } else {
        // When offline, get from local storage and calculate distances
        final facilities = await LocalStorageService.getMedicalFacilities();
        for (int i = 0; i < facilities.length; i++) {
          var facility = facilities[i];
          final distance = await LocationService.calculateDistance(
            latitude,
            longitude,
            facility.latitude,
            facility.longitude,
          );
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
        // Sort by distance
        facilities.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
        return facilities;
      }
    } catch (e) {
      print('Error getting nearby medical facilities: $e');
      return [];
    }
  }

  // User Profile
  Future<UserProfile?> getUserProfile() async {
    try {
      if (await isConnected()) {
        final profile = await _firebaseService.getUserProfile();
        if (profile != null) {
          // Save to local storage for offline access
          await LocalStorageService.saveUserProfile(profile);
        }
        return profile;
      } else {
        return await LocalStorageService.getUserProfile();
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return await LocalStorageService.getUserProfile();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      if (await isConnected()) {
        await _firebaseService.saveUserProfile(profile);
      }
      // Always save to local storage
      await LocalStorageService.saveUserProfile(profile);
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Load initial data from assets
  Future<void> loadInitialData() async {
    // Check if data is already loaded
    bool isDataLoaded = await LocalStorageService.isDataLoaded();
    if (!isDataLoaded) {
      // Load first aid instructions from assets
      final String firstAidJson = await rootBundle.loadString('assets/data/first_aid_instructions.json');
      final List<dynamic> firstAidData = json.decode(firstAidJson);
      final List<FirstAidInstruction> instructions = firstAidData
          .map((data) => FirstAidInstruction.fromJson(data))
          .toList();
      await LocalStorageService.saveFirstAidInstructions(instructions);

      // Load illnesses from assets
      final String illnessesJson = await rootBundle.loadString('assets/data/illnesses.json');
      final List<dynamic> illnessesData = json.decode(illnessesJson);
      final List<Illness> illnesses = illnessesData
          .map((data) => Illness.fromJson(data))
          .toList();
      await LocalStorageService.saveIllnesses(illnesses);
    }
  }

  // Get personalized treatment recommendations based on user profile
  Future<List<String>> getPersonalizedRecommendations(String illnessId, UserProfile userProfile) async {
    final illness = await getIllnessById(illnessId);
    if (illness == null) {
      return [];
    }

    List<String> recommendations = [];

    // Check for allergies
    for (String allergy in userProfile.allergies) {
      if (illness.treatments.any((treatment) => treatment.toLowerCase().contains(allergy.toLowerCase()))) {
        recommendations.add('Caution: You have an allergy to $allergy which may affect some treatments for ${illness.name}.');
      }
    }

    // Check for existing medical conditions
    for (String condition in userProfile.medicalConditions) {
      if (condition.toLowerCase() == 'diabetes' &&
          (illness.name.toLowerCase() == 'dehydration' ||
           illness.name.toLowerCase() == 'food poisoning')) {
        recommendations.add('Important: As a diabetic, monitor your blood sugar levels closely with ${illness.name}.');
      }

      if (condition.toLowerCase() == 'asthma' &&
          illness.name.toLowerCase() == 'allergic reaction') {
        recommendations.add('Warning: Your asthma may be triggered during an allergic reaction. Keep your inhaler accessible.');
      }

      // Add more condition-specific recommendations
    }

    // Age-specific recommendations
    if (userProfile.age > 65) {
      recommendations.add('For seniors: Seek medical attention sooner as symptoms may progress more rapidly.');
    } else if (userProfile.age < 12) {
      recommendations.add('For children: Dosages and treatment approaches may need to be adjusted. Consult a pediatrician.');
    }

    // If no specific recommendations, add a general one
    if (recommendations.isEmpty) {
      recommendations.add('Based on your profile, standard treatment guidelines for ${illness.name} apply.');
    }

    return recommendations;
  }
}