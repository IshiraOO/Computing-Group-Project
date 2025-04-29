import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/symptom_analysis.dart';
import '../models/illness.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';

class SymptomAnalysisService {
  static const String symptomAnalysisBoxName = 'symptom_analysis';
  static const Uuid _uuid = Uuid();

  // Common symptoms and their follow-up questions
  static final Map<String, List<SymptomQuestion>> _symptomQuestions = {
    'headache': [
      SymptomQuestion(
        id: 'headache_severity',
        question: 'How would you rate your headache pain?',
        options: ['Mild', 'Moderate', 'Severe', 'Worst of my life'],
        questionType: 'multiple_choice',
      ),
      SymptomQuestion(
        id: 'headache_location',
        question: 'Where is the pain located?',
        options: ['Front of head', 'Back of head', 'One side', 'All over'],
        questionType: 'multiple_choice',
      ),
      SymptomQuestion(
        id: 'headache_duration',
        question: 'How long have you had this headache?',
        options: ['Less than 1 hour', '1-24 hours', '1-3 days', 'More than 3 days'],
        questionType: 'multiple_choice',
      ),
    ],
    'fever': [
      SymptomQuestion(
        id: 'fever_temperature',
        question: 'What is your temperature (if known)?',
        questionType: 'text',
      ),
      SymptomQuestion(
        id: 'fever_duration',
        question: 'How long have you had the fever?',
        options: ['Less than 24 hours', '1-3 days', 'More than 3 days'],
        questionType: 'multiple_choice',
      ),
    ],
    'cough': [
      SymptomQuestion(
        id: 'cough_type',
        question: 'What type of cough do you have?',
        options: ['Dry', 'Wet/Productive', 'Both'],
        questionType: 'multiple_choice',
      ),
      SymptomQuestion(
        id: 'cough_duration',
        question: 'How long have you been coughing?',
        options: ['Less than 1 week', '1-3 weeks', 'More than 3 weeks'],
        questionType: 'multiple_choice',
      ),
    ],
    // Add more symptoms and their questions as needed
  };

  // Initialize the symptom analysis box
  static Future<Box> _openSymptomAnalysisBox() async {
    return await Hive.openBox(symptomAnalysisBoxName);
  }

  // Get questions for a specific symptom
  static List<SymptomQuestion> getQuestionsForSymptom(String symptom) {
    final lowerSymptom = symptom.toLowerCase();
    return _symptomQuestions[lowerSymptom] ?? [];
  }

  // Start a new symptom analysis session
  static Future<SymptomAnalysis> startAnalysis({
    required String userId,
    required List<String> initialSymptoms,
  }) async {
    final id = _uuid.v4();
    final timestamp = DateTime.now();

    final analysis = SymptomAnalysis(
      id: id,
      timestamp: timestamp,
      userId: userId,
      reportedSymptoms: initialSymptoms,
      userResponses: {},
      recommendedActions: [],
      urgencyLevel: 'analyzing', // Will be updated as the analysis progresses
      aiRecommendation: '',
    );

    // Save the initial analysis
    final box = await _openSymptomAnalysisBox();
    await box.put(id, jsonEncode(analysis.toJson()));

    return analysis;
  }

  // Update an existing analysis with new responses
  static Future<SymptomAnalysis> updateAnalysis({
    required String analysisId,
    required Map<String, dynamic> newResponses,
  }) async {
    final box = await _openSymptomAnalysisBox();
    final String? jsonString = box.get(analysisId);

    if (jsonString == null) {
      throw Exception('Analysis not found');
    }

    final Map<String, dynamic> json = jsonDecode(jsonString);
    final analysis = SymptomAnalysis.fromJson(json);

    // Merge new responses with existing ones
    final updatedResponses = {...analysis.userResponses, ...newResponses};

    final updatedAnalysis = analysis.copyWith(
      userResponses: updatedResponses,
    );

    // Save the updated analysis
    await box.put(analysisId, jsonEncode(updatedAnalysis.toJson()));

    return updatedAnalysis;
  }

  // Complete the analysis with recommendations
  static Future<SymptomAnalysis> completeAnalysis({
    required String analysisId,
    required List<String> recommendedActions,
    required List<String> possibleConditions,
    required String urgencyLevel,
    required String aiRecommendation,
  }) async {
    final box = await _openSymptomAnalysisBox();
    final String? jsonString = box.get(analysisId);

    if (jsonString == null) {
      throw Exception('Analysis not found');
    }

    final Map<String, dynamic> json = jsonDecode(jsonString);
    final analysis = SymptomAnalysis.fromJson(json);

    final completedAnalysis = analysis.copyWith(
      recommendedActions: recommendedActions,
      possibleConditions: possibleConditions,
      urgencyLevel: urgencyLevel,
      aiRecommendation: aiRecommendation,
    );

    // Save the completed analysis
    await box.put(analysisId, jsonEncode(completedAnalysis.toJson()));

    return completedAnalysis;
  }

  // Get all analyses for a user
  static Future<List<SymptomAnalysis>> getUserAnalyses(String userId) async {
    final box = await _openSymptomAnalysisBox();
    final List<SymptomAnalysis> analyses = [];

    for (var key in box.keys) {
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        final analysis = SymptomAnalysis.fromJson(json);
        if (analysis.userId == userId) {
          analyses.add(analysis);
        }
      }
    }

    // Sort by timestamp (newest first)
    analyses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return analyses;
  }

  // Get a specific analysis by ID
  static Future<SymptomAnalysis?> getAnalysisById(String id) async {
    final box = await _openSymptomAnalysisBox();
    final String? jsonString = box.get(id);

    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return SymptomAnalysis.fromJson(json);
    }

    return null;
  }

  // Save analysis to health journal
  static Future<void> saveAnalysisToJournal(String analysisId) async {
    final box = await _openSymptomAnalysisBox();
    final String? jsonString = box.get(analysisId);

    if (jsonString == null) {
      throw Exception('Analysis not found');
    }

    final Map<String, dynamic> json = jsonDecode(jsonString);
    final analysis = SymptomAnalysis.fromJson(json);

    final updatedAnalysis = analysis.copyWith(
      savedToJournal: true,
    );

    // Save the updated analysis
    await box.put(analysisId, jsonEncode(updatedAnalysis.toJson()));
  }

  // Delete an analysis
  static Future<void> deleteAnalysis(String id) async {
    final box = await _openSymptomAnalysisBox();
    await box.delete(id);
  }

  // Analyze symptoms and provide recommendations
  static Future<Map<String, dynamic>> analyzeSymptoms({
    required List<String> symptoms,
    required Map<String, dynamic> responses,
    UserProfile? userProfile,
  }) async {
    // This is a simplified version of symptom analysis
    // In a real app, this would use a medical API or more sophisticated algorithm

    // Get all illnesses from local storage
    final illnesses = await LocalStorageService.getIllnesses();

    // Find potential matches based on symptoms
    final List<Illness> potentialMatches = [];
    final List<String> possibleConditions = [];

    for (var illness in illnesses) {
      int matchCount = 0;
      for (var symptom in symptoms) {
        if (illness.symptoms.any((s) => s.toLowerCase().contains(symptom.toLowerCase()))) {
          matchCount++;
        }
      }

      // If more than half of the symptoms match, consider it a potential match
      if (matchCount > 0 && matchCount >= symptoms.length / 2) {
        potentialMatches.add(illness);
        possibleConditions.add(illness.name);
      }
    }

    // Determine urgency level
    String urgencyLevel = 'non-urgent';
    final List<String> emergencySymptoms = [
      'chest pain', 'difficulty breathing', 'severe bleeding',
      'unconscious', 'seizure', 'stroke', 'worst headache',
      'severe allergic reaction', 'poisoning'
    ];

    for (var symptom in symptoms) {
      if (emergencySymptoms.any((s) => symptom.toLowerCase().contains(s))) {
        urgencyLevel = 'emergency';
        break;
      }
    }

    // If not emergency but severe symptoms, mark as urgent
    if (urgencyLevel != 'emergency') {
      final List<String> urgentSymptoms = [
        'high fever', 'severe pain', 'dehydration', 'broken bone',
        'deep cut', 'burn', 'head injury'
      ];

      for (var symptom in symptoms) {
        if (urgentSymptoms.any((s) => symptom.toLowerCase().contains(s))) {
          urgencyLevel = 'urgent';
          break;
        }
      }
    }

    // Generate recommended actions based on urgency
    final List<String> recommendedActions = [];

    if (urgencyLevel == 'emergency') {
      recommendedActions.add('Call emergency services (911) immediately');
      recommendedActions.add('Do not drive yourself to the hospital');
    } else if (urgencyLevel == 'urgent') {
      recommendedActions.add('Seek medical attention within the next few hours');
      recommendedActions.add('Visit an urgent care center or emergency room');
    } else {
      recommendedActions.add('Monitor your symptoms');
      recommendedActions.add('Rest and stay hydrated');
      recommendedActions.add('Consider scheduling an appointment with your doctor');
    }

    // Add condition-specific recommendations
    for (var illness in potentialMatches) {
      for (var treatment in illness.treatments) {
        if (!recommendedActions.contains(treatment)) {
          recommendedActions.add(treatment);
        }
      }
    }

    // Generate AI recommendation text
    String aiRecommendation = '';

    if (urgencyLevel == 'emergency') {
      aiRecommendation = 'Based on your symptoms, this appears to be a medical emergency. '
          'Please call emergency services (911) immediately or have someone take you to the nearest emergency room.';
    } else if (urgencyLevel == 'urgent') {
      aiRecommendation = 'Your symptoms suggest a condition that requires prompt medical attention. '
          'Please visit an urgent care center or emergency room within the next few hours.';
    } else {
      if (potentialMatches.isNotEmpty) {
        aiRecommendation = 'Based on your symptoms, you may be experiencing ${possibleConditions.join(' or ')}. '
            'Follow the recommended actions and consult with a healthcare provider for proper diagnosis and treatment.';
      } else {
        aiRecommendation = 'Your symptoms don\'t immediately suggest a serious condition, but monitor them closely. '
            'If they worsen or persist, please consult with a healthcare provider.';
      }
    }

    return {
      'recommendedActions': recommendedActions,
      'possibleConditions': possibleConditions,
      'urgencyLevel': urgencyLevel,
      'aiRecommendation': aiRecommendation,
    };
  }
}