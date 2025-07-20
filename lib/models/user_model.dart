class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String password;
  final DateTime? createdAt;
  final String? address;
  final int? age;
  final String? gender;
  final List<String> joinedEventIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.password,
    this.createdAt,
    this.address,
    this.age,
    this.gender,
    this.joinedEventIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
      'address': address,
      'age': age,
      'gender': gender,
      'joinedEventIds': joinedEventIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      password: map['password'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      address: map['address'],
      age: map['age'],
      gender: map['gender'],
      joinedEventIds: (map['joinedEventIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
} 