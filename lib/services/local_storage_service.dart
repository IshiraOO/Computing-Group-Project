import 'dart:convert';
import 'package:first_aid_health_care/models/emergency_contact.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/first_aid_instruction.dart';
import '../models/illness.dart';
import '../models/medical_facility.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const String firstAidBoxName = 'firstAidInstructions';
  static const String illnessBoxName = 'illnesses';
  static const String medicalFacilitiesBoxName = 'medicalFacilities';
  static const String userProfileBoxName = 'userProfile';
  static const String emergencyContactsBoxName = 'emergencyContacts';

  // Initialize Hive
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  }

  // First Aid Instructions
  static Future<void> saveFirstAidInstructions(List<FirstAidInstruction> instructions) async {
    final box = await Hive.openBox(firstAidBoxName);
    await box.clear();

    for (var instruction in instructions) {
      await box.put(instruction.id, jsonEncode(instruction.toJson()));
    }
  }

  static Future<List<FirstAidInstruction>> getFirstAidInstructions() async {
    final box = await Hive.openBox(firstAidBoxName);
    final List<FirstAidInstruction> instructions = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        instructions.add(FirstAidInstruction.fromJson(json));
      }
    }

    return instructions;
  }

  static Future<FirstAidInstruction?> getFirstAidInstructionById(String id) async {
    final box = await Hive.openBox(firstAidBoxName);
    final String? jsonString = box.get(id);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return FirstAidInstruction.fromJson(json);
    }

    return null;
  }

  // Illnesses
  static Future<void> saveIllnesses(List<Illness> illnesses) async {
    final box = await Hive.openBox(illnessBoxName);
    await box.clear();

    for (var illness in illnesses) {
      await box.put(illness.id, jsonEncode(illness.toJson()));
    }
  }

  static Future<List<Illness>> getIllnesses() async {
    final box = await Hive.openBox(illnessBoxName);
    final List<Illness> illnesses = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        illnesses.add(Illness.fromJson(json));
      }
    }

    return illnesses;
  }

  static Future<Illness?> getIllnessById(String id) async {
    final box = await Hive.openBox(illnessBoxName);
    final String? jsonString = box.get(id);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Illness.fromJson(json);
    }

    return null;
  }

  // Medical Facilities
  static Future<void> saveMedicalFacilities(List<MedicalFacility> facilities) async {
    final box = await Hive.openBox(medicalFacilitiesBoxName);
    await box.clear();

    for (var facility in facilities) {
      await box.put(facility.id, jsonEncode(facility.toJson()));
    }
  }

  static Future<List<MedicalFacility>> getMedicalFacilities() async {
    final box = await Hive.openBox(medicalFacilitiesBoxName);
    final List<MedicalFacility> facilities = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        facilities.add(MedicalFacility.fromJson(json));
      }
    }

    return facilities;
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile userProfile) async {
    final box = await Hive.openBox(userProfileBoxName);
    await box.put('userProfile', jsonEncode(userProfile.toJson()));
  }

  static Future<UserProfile?> getUserProfile() async {
    final box = await Hive.openBox(userProfileBoxName);
    final String? jsonString = box.get('userProfile');

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    }

    return null;
  }

  // Emergency Contacts
  static Future<void> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final box = await Hive.openBox(emergencyContactsBoxName);
    await box.clear();

    for (var contact in contacts) {
      await box.put(contact.id, jsonEncode(contact.toJson()));
    }
  }

  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    final box = await Hive.openBox(emergencyContactsBoxName);
    final List<EmergencyContact> contacts = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        contacts.add(EmergencyContact.fromJson(json));
      }
    }

    return contacts;
  }

  static Future<void> addEmergencyContact(EmergencyContact contact) async {
    final box = await Hive.openBox(emergencyContactsBoxName);
    await box.put(contact.id, jsonEncode(contact.toJson()));
  }

  static Future<void> updateEmergencyContact(EmergencyContact contact) async {
    final box = await Hive.openBox(emergencyContactsBoxName);
    await box.put(contact.id, jsonEncode(contact.toJson()));
  }

  static Future<void> deleteEmergencyContact(String id) async {
    final box = await Hive.openBox(emergencyContactsBoxName);
    await box.delete(id);
  }

  // Load initial data from assets
  static Future<void> loadInitialData() async {
    // This method would be called when the app is first installed
    // It would load the initial data from the assets folder into Hive
    // Implementation would depend on how the assets are structured
  }

  // Check if data is already loaded
  static Future<bool> isDataLoaded() async {
    final box = await Hive.openBox(firstAidBoxName);
    return box.isNotEmpty;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk(firstAidBoxName);
    await Hive.deleteBoxFromDisk(illnessBoxName);
    await Hive.deleteBoxFromDisk(medicalFacilitiesBoxName);
    await Hive.deleteBoxFromDisk(userProfileBoxName);
    await Hive.deleteBoxFromDisk(emergencyContactsBoxName);
  }
}