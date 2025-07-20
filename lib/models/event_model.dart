class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int capacity;
  final String createdBy;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.capacity,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'capacity': capacity,
      'createdBy': createdBy,
    };
  }

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 0,
      createdBy: map['createdBy'] ?? '',
    );
  }
} 