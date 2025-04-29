class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimaryContact;
  final bool notifyInEmergency;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = '',
    this.isPrimaryContact = false,
    this.notifyInEmergency = true,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String? ?? '',
      isPrimaryContact: json['isPrimaryContact'] as bool? ?? false,
      notifyInEmergency: json['notifyInEmergency'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'isPrimaryContact': isPrimaryContact,
      'notifyInEmergency': notifyInEmergency,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isPrimaryContact,
    bool? notifyInEmergency,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      notifyInEmergency: notifyInEmergency ?? this.notifyInEmergency,
    );
  }
}