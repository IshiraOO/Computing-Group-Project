import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/training_module.dart';

class TrainingModuleService {
  static const String trainingModuleBoxName = 'training_modules';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String modulesCollection = 'training_modules';
  static const Uuid _uuid = Uuid();

  // Initialize the training module box for offline storage
  static Future<Box> _openTrainingModuleBox() async {
    return await Hive.openBox(trainingModuleBoxName);
  }

  // Fetch all training modules from Firebase
  static Future<List<TrainingModule>> fetchAllModules() async {
    try {
      final snapshot = await _firestore.collection(modulesCollection).get();
      final modules = snapshot.docs.map((doc) => TrainingModule.fromJson(doc.data())).toList();

      // Save to local storage for offline access
      await _saveModulesToLocalStorage(modules);

      return modules;
    } catch (e) {
      // If online fetch fails, try to get from local storage
      return await getModulesFromLocalStorage();
    }
  }

  // Get modules by target role
  static Future<List<TrainingModule>> getModulesByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(modulesCollection)
          .where('targetRole', isEqualTo: role)
          .get();

      return snapshot.docs.map((doc) => TrainingModule.fromJson(doc.data())).toList();
    } catch (e) {
      // If online fetch fails, filter from local storage
      final allModules = await getModulesFromLocalStorage();
      return allModules.where((module) => module.targetRole == role).toList();
    }
  }

  // Get a single module by ID
  static Future<TrainingModule?> getModuleById(String id) async {
    try {
      final doc = await _firestore.collection(modulesCollection).doc(id).get();
      if (doc.exists) {
        return TrainingModule.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      // If online fetch fails, try to get from local storage
      return await getModuleFromLocalStorage(id);
    }
  }

  // Save modules to local storage for offline access
  static Future<void> _saveModulesToLocalStorage(List<TrainingModule> modules) async {
    final box = await _openTrainingModuleBox();
    await box.clear();

    for (var module in modules) {
      await box.put(module.id, jsonEncode(module.toJson()));
    }
  }

  // Get all modules from local storage
  static Future<List<TrainingModule>> getModulesFromLocalStorage() async {
    final box = await _openTrainingModuleBox();
    final List<TrainingModule> modules = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        modules.add(TrainingModule.fromJson(json));
      }
    }

    return modules;
  }

  // Get a single module from local storage
  static Future<TrainingModule?> getModuleFromLocalStorage(String id) async {
    final box = await _openTrainingModuleBox();
    final String? jsonString = box.get(id);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return TrainingModule.fromJson(json);
    }

    return null;
  }

  // Get available roles for training modules
  static Future<List<String>> getAvailableRoles() async {
    final modules = await fetchAllModules();
    final Set<String> roles = {};

    for (var module in modules) {
      roles.add(module.targetRole);
    }

    return roles.toList();
  }

  // Create a new training module (admin function)
  static Future<TrainingModule> createModule({
    required String title,
    required String description,
    required String targetRole,
    required List<TrainingSection> sections,
    String imageUrl = '',
    String difficulty = 'beginner',
    int estimatedTimeMinutes = 30,
    Map<String, dynamic> additionalInfo = const {},
  }) async {
    final id = _uuid.v4();

    final module = TrainingModule(
      id: id,
      title: title,
      description: description,
      targetRole: targetRole,
      sections: sections,
      imageUrl: imageUrl,
      difficulty: difficulty,
      estimatedTimeMinutes: estimatedTimeMinutes,
      additionalInfo: additionalInfo,
    );

    await _firestore.collection(modulesCollection).doc(id).set(module.toJson());

    // Also save to local storage
    final box = await _openTrainingModuleBox();
    await box.put(id, jsonEncode(module.toJson()));

    return module;
  }
}