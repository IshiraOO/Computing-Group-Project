class Illness {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> preventions;
  final String severity; // 'mild', 'moderate', 'severe'
  final String imageUrl;
  final bool requiresMedicalAttention;
  final Map<String, dynamic> additionalInfo; // For any extra information

  Illness({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatments,
    this.preventions = const [],
    this.severity = 'moderate',
    this.imageUrl = '',
    this.requiresMedicalAttention = false,
    this.additionalInfo = const {},
  });

  factory Illness.fromJson(Map<String, dynamic> json) {
    return Illness(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms']),
      treatments: List<String>.from(json['treatments']),
      preventions: json['preventions'] != null ? List<String>.from(json['preventions']) : [],
      severity: json['severity'] as String? ?? 'moderate',
      imageUrl: json['imageUrl'] as String? ?? '',
      requiresMedicalAttention: json['requiresMedicalAttention'] as bool? ?? false,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'treatments': treatments,
      'preventions': preventions,
      'severity': severity,
      'imageUrl': imageUrl,
      'requiresMedicalAttention': requiresMedicalAttention,
      'additionalInfo': additionalInfo,
    };
  }
}