import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/health_journal_entry.dart';

class HealthJournalService {
  static const String healthJournalBoxName = 'health_journal';
  static const Uuid _uuid = Uuid();

  // Initialize the health journal box
  static Future<Box> _openHealthJournalBox() async {
    return await Hive.openBox(healthJournalBoxName);
  }

  // Add a new journal entry
  static Future<HealthJournalEntry> addJournalEntry({
    required String title,
    required String description,
    List<String> symptoms = const [],
    List<String> medications = const [],
    List<String> treatments = const [],
    double? temperature,
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    Map<String, dynamic> additionalData = const {},
  }) async {
    final box = await _openHealthJournalBox();
    final id = _uuid.v4();
    final date = DateTime.now();

    final entry = HealthJournalEntry(
      id: id,
      date: date,
      title: title,
      description: description,
      symptoms: symptoms,
      medications: medications,
      treatments: treatments,
      temperature: temperature,
      heartRate: heartRate,
      bloodPressureSystolic: bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic,
      additionalData: additionalData,
    );

    await box.put(id, jsonEncode(entry.toJson()));
    return entry;
  }

  // Get all journal entries
  static Future<List<HealthJournalEntry>> getAllJournalEntries() async {
    final box = await _openHealthJournalBox();
    final List<HealthJournalEntry> entries = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        entries.add(HealthJournalEntry.fromJson(json));
      }
    }

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  // Get a journal entry by ID
  static Future<HealthJournalEntry?> getJournalEntryById(String id) async {
    final box = await _openHealthJournalBox();
    final String? jsonString = box.get(id);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return HealthJournalEntry.fromJson(json);
    }

    return null;
  }

  // Update a journal entry
  static Future<void> updateJournalEntry(HealthJournalEntry entry) async {
    final box = await _openHealthJournalBox();
    await box.put(entry.id, jsonEncode(entry.toJson()));
  }

  // Delete a journal entry
  static Future<void> deleteJournalEntry(String id) async {
    final box = await _openHealthJournalBox();
    await box.delete(id);
  }

  // Get entries by date range
  static Future<List<HealthJournalEntry>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEntries = await getAllJournalEntries();

    return allEntries.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Search entries by keyword
  static Future<List<HealthJournalEntry>> searchEntries(String keyword) async {
    final allEntries = await getAllJournalEntries();
    final lowercaseKeyword = keyword.toLowerCase();

    return allEntries.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseKeyword) ||
             entry.description.toLowerCase().contains(lowercaseKeyword) ||
             entry.symptoms.any((s) => s.toLowerCase().contains(lowercaseKeyword)) ||
             entry.medications.any((m) => m.toLowerCase().contains(lowercaseKeyword)) ||
             entry.treatments.any((t) => t.toLowerCase().contains(lowercaseKeyword));
    }).toList();
  }

  // Export all entries as JSON
  static Future<String> exportJournalAsJson() async {
    final entries = await getAllJournalEntries();
    final List<Map<String, dynamic>> jsonList = entries.map((e) => e.toJson()).toList();
    return jsonEncode(jsonList);
  }

  // Import entries from JSON
  static Future<void> importJournalFromJson(String jsonString) async {
    final box = await _openHealthJournalBox();
    final List<dynamic> jsonList = jsonDecode(jsonString);

    for (var json in jsonList) {
      final entry = HealthJournalEntry.fromJson(json);
      await box.put(entry.id, jsonEncode(entry.toJson()));
    }
  }

  // Clear all entries
  static Future<void> clearAllEntries() async {
    final box = await _openHealthJournalBox();
    await box.clear();
  }
}