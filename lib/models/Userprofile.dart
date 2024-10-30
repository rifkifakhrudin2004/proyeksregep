class UserProfile {
  String id;
  String name;
  int age;
  String dateOfBirth;
  String? photoUrl; // New field for profile photo URL

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.dateOfBirth,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'photoUrl': photoUrl, // Include photoUrl in map
    };
  }

  UserProfile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        age = map['age'],
        dateOfBirth = map['dateOfBirth'],
        photoUrl = map['photoUrl']; // Initialize photoUrl
}
