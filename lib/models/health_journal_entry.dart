class HealthJournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final List<String> symptoms;
  final List<String> medications;
  final List<String> treatments;
  final double? temperature; // in Celsius
  final int? heartRate; // in BPM
  final int? bloodPressureSystolic; // in mmHg
  final int? bloodPressureDiastolic; // in mmHg
  final Map<String, dynamic> additionalData; // For any extra measurements or notes

  HealthJournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    this.symptoms = const [],
    this.medications = const [],
    this.treatments = const [],
    this.temperature,
    this.heartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.additionalData = const {},
  });

  factory HealthJournalEntry.fromJson(Map<String, dynamic> json) {
    return HealthJournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      symptoms: json['symptoms'] != null ? List<String>.from(json['symptoms']) : [],
      medications: json['medications'] != null ? List<String>.from(json['medications']) : [],
      treatments: json['treatments'] != null ? List<String>.from(json['treatments']) : [],
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      heartRate: json['heartRate'] as int?,
      bloodPressureSystolic: json['bloodPressureSystolic'] as int?,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as int?,
      additionalData: json['additionalData'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'symptoms': symptoms,
      'medications': medications,
      'treatments': treatments,
      'temperature': temperature,
      'heartRate': heartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'additionalData': additionalData,
    };
  }

  HealthJournalEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    List<String>? symptoms,
    List<String>? medications,
    List<String>? treatments,
    double? temperature,
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    Map<String, dynamic>? additionalData,
  }) {
    return HealthJournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      medications: medications ?? this.medications,
      treatments: treatments ?? this.treatments,
      temperature: temperature ?? this.temperature,
      heartRate: heartRate ?? this.heartRate,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}