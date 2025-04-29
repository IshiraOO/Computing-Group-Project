class FirstAidInstruction {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final String videoUrl;
  final String imageUrl;
  final List<String> dosList;
  final List<String> dontsList;
  final String emergencyLevel; // 'high', 'medium', 'low'

  FirstAidInstruction({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.videoUrl,
    this.imageUrl = '',
    this.dosList = const [],
    this.dontsList = const [],
    this.emergencyLevel = 'medium',
  });

  factory FirstAidInstruction.fromJson(Map<String, dynamic> json) {
    return FirstAidInstruction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: List<String>.from(json['steps']),
      videoUrl: json['videoUrl'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      dosList: json['dosList'] != null ? List<String>.from(json['dosList']) : [],
      dontsList: json['dontsList'] != null ? List<String>.from(json['dontsList']) : [],
      emergencyLevel: json['emergencyLevel'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'dosList': dosList,
      'dontsList': dontsList,
      'emergencyLevel': emergencyLevel,
    };
  }
}