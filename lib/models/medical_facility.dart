class MedicalFacility {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String website;
  final List<String> services;
  final String facilityType; // 'hospital', 'clinic', 'pharmacy', etc.
  final bool isOpen24Hours;
  final Map<String, String> operatingHours;
  final double rating; // Out of 5
  final int distanceInMeters; // Distance from user's current location

  MedicalFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber = '',
    this.website = '',
    this.services = const [],
    this.facilityType = 'hospital',
    this.isOpen24Hours = false,
    this.operatingHours = const {},
    this.rating = 0.0,
    this.distanceInMeters = 0,
  });

  factory MedicalFacility.fromJson(Map<String, dynamic> json) {
    return MedicalFacility(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String? ?? '',
      website: json['website'] as String? ?? '',
      services: json['services'] != null ? List<String>.from(json['services']) : [],
      facilityType: json['facilityType'] as String? ?? 'hospital',
      isOpen24Hours: json['isOpen24Hours'] as bool? ?? false,
      operatingHours: json['operatingHours'] != null
          ? Map<String, String>.from(json['operatingHours'])
          : {},
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distanceInMeters: json['distanceInMeters'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'website': website,
      'services': services,
      'facilityType': facilityType,
      'isOpen24Hours': isOpen24Hours,
      'operatingHours': operatingHours,
      'rating': rating,
      'distanceInMeters': distanceInMeters,
    };
  }
}