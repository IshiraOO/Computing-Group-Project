class UserProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final double weight; // in kg
  final double height; // in cm
  final List<String> allergies;
  final List<String> medications;
  final List<String> medicalConditions;
  final List<String> emergencyContacts; // List of contact IDs
  final Map<String, dynamic> additionalInfo;

  // Getter to calculate age from dateOfBirth
  int get age {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  UserProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.weight = 0,
    this.height = 0,
    this.allergies = const [],
    this.medications = const [],
    this.medicalConditions = const [],
    this.emergencyContacts = const [],
    this.additionalInfo = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : [],
      medications: json['medications'] != null ? List<String>.from(json['medications']) : [],
      medicalConditions: json['medicalConditions'] != null ? List<String>.from(json['medicalConditions']) : [],
      emergencyContacts: json['emergencyContacts'] != null ? List<String>.from(json['emergencyContacts']) : [],
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'allergies': allergies,
      'medications': medications,
      'medicalConditions': medicalConditions,
      'emergencyContacts': emergencyContacts,
      'additionalInfo': additionalInfo,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    double? height,
    List<String>? allergies,
    List<String>? medications,
    List<String>? medicalConditions,
    List<String>? emergencyContacts,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}