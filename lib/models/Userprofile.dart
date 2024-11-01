class UserProfile {
  final String id;
  final String name;
  final int age;
  final String dateOfBirth;
  final String phoneNumber;
  final List<String> photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.dateOfBirth,
    required this.phoneNumber,
    this.photoUrl = const [],
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      dateOfBirth: map['dateOfBirth'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: List<String>.from(map['photoUrl'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
    };
  }
}