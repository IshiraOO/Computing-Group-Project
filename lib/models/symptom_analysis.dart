class SymptomAnalysis {
  final String id;
  final DateTime timestamp;
  final String userId;
  final List<String> reportedSymptoms;
  final Map<String, dynamic> userResponses; // Stores Q&A interactions
  final List<String> recommendedActions;
  final List<String> possibleConditions;
  final String urgencyLevel; // 'emergency', 'urgent', 'non-urgent', 'self-care'
  final String aiRecommendation;
  final bool savedToJournal;
  final Map<String, dynamic> additionalData; // For any extra information

  SymptomAnalysis({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.reportedSymptoms,
    required this.userResponses,
    required this.recommendedActions,
    this.possibleConditions = const [],
    required this.urgencyLevel,
    required this.aiRecommendation,
    this.savedToJournal = false,
    this.additionalData = const {},
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      reportedSymptoms: List<String>.from(json['reportedSymptoms']),
      userResponses: json['userResponses'] as Map<String, dynamic>,
      recommendedActions: List<String>.from(json['recommendedActions']),
      possibleConditions: json['possibleConditions'] != null
          ? List<String>.from(json['possibleConditions'])
          : [],
      urgencyLevel: json['urgencyLevel'] as String,
      aiRecommendation: json['aiRecommendation'] as String,
      savedToJournal: json['savedToJournal'] as bool? ?? false,
      additionalData: json['additionalData'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'reportedSymptoms': reportedSymptoms,
      'userResponses': userResponses,
      'recommendedActions': recommendedActions,
      'possibleConditions': possibleConditions,
      'urgencyLevel': urgencyLevel,
      'aiRecommendation': aiRecommendation,
      'savedToJournal': savedToJournal,
      'additionalData': additionalData,
    };
  }

  SymptomAnalysis copyWith({
    String? id,
    DateTime? timestamp,
    String? userId,
    List<String>? reportedSymptoms,
    Map<String, dynamic>? userResponses,
    List<String>? recommendedActions,
    List<String>? possibleConditions,
    String? urgencyLevel,
    String? aiRecommendation,
    bool? savedToJournal,
    Map<String, dynamic>? additionalData,
  }) {
    return SymptomAnalysis(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      reportedSymptoms: reportedSymptoms ?? this.reportedSymptoms,
      userResponses: userResponses ?? this.userResponses,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      possibleConditions: possibleConditions ?? this.possibleConditions,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      savedToJournal: savedToJournal ?? this.savedToJournal,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

class SymptomQuestion {
  final String id;
  final String question;
  final List<String> options; // For multiple choice questions
  final String questionType; // 'multiple_choice', 'yes_no', 'text', 'scale'
  final Map<String, dynamic> metadata; // For conditional logic or scoring

  SymptomQuestion({
    required this.id,
    required this.question,
    this.options = const [],
    required this.questionType,
    this.metadata = const {},
  });

  factory SymptomQuestion.fromJson(Map<String, dynamic> json) {
    return SymptomQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: json['options'] != null ? List<String>.from(json['options']) : [],
      questionType: json['questionType'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'questionType': questionType,
      'metadata': metadata,
    };
  }
}