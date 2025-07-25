class RegistrationModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registrationDate;
  // Catering-specific fields
  final String cateringServiceType; // e.g., Buffet, Plated, etc.
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final String status; // e.g., pending, approved, declined

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registrationDate,
    required this.cateringServiceType,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'registrationDate': registrationDate.toIso8601String(),
      'cateringServiceType': cateringServiceType,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventLocation': eventLocation,
      'status': status,
    };
  }

  factory RegistrationModel.fromMap(Map<String, dynamic> map) {
    return RegistrationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      eventId: map['eventId'] ?? '',
      registrationDate: DateTime.parse(map['registrationDate']),
      cateringServiceType: map['cateringServiceType'] ?? '',
      eventName: map['eventName'] ?? '',
      eventDate: DateTime.parse(map['eventDate']),
      eventLocation: map['eventLocation'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
} 