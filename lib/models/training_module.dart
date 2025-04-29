class TrainingModule {
  final String id;
  final String title;
  final String description;
  final String targetRole; // e.g., 'parent', 'hiker', 'teacher', etc.
  final List<TrainingSection> sections;
  final String imageUrl;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final int estimatedTimeMinutes; // estimated completion time in minutes
  final Map<String, dynamic> additionalInfo; // For any extra information

  TrainingModule({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRole,
    required this.sections,
    this.imageUrl = '',
    this.difficulty = 'beginner',
    this.estimatedTimeMinutes = 30,
    this.additionalInfo = const {},
  });

  factory TrainingModule.fromJson(Map<String, dynamic> json) {
    return TrainingModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetRole: json['targetRole'] as String,
      sections: (json['sections'] as List)
          .map((section) => TrainingSection.fromJson(section))
          .toList(),
      imageUrl: json['imageUrl'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int? ?? 30,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetRole': targetRole,
      'sections': sections.map((section) => section.toJson()).toList(),
      'imageUrl': imageUrl,
      'difficulty': difficulty,
      'estimatedTimeMinutes': estimatedTimeMinutes,
      'additionalInfo': additionalInfo,
    };
  }
}

class TrainingSection {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<TrainingQuiz>? quizzes;

  TrainingSection({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    this.quizzes,
  });

  factory TrainingSection.fromJson(Map<String, dynamic> json) {
    return TrainingSection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      videoUrl: json['videoUrl'] as String?,
      quizzes: json['quizzes'] != null
          ? (json['quizzes'] as List)
              .map((quiz) => TrainingQuiz.fromJson(quiz))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'quizzes': quizzes?.map((quiz) => quiz.toJson()).toList(),
    };
  }
}

class TrainingQuiz {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  TrainingQuiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory TrainingQuiz.fromJson(Map<String, dynamic> json) {
    return TrainingQuiz(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }
}