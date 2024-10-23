class UserProfile {
  String id;
  String name;
  int age;
  String dateOfBirth;

  UserProfile({required this.id, required this.name, required this.age, required this.dateOfBirth});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'dateOfBirth': dateOfBirth,
    };
  }

  UserProfile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        age = map['age'],
        dateOfBirth = map['dateOfBirth'];
}
