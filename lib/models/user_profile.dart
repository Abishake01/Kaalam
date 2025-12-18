class UserProfile {
  final int age; // in years
  final String profession; // e.g., 'software_engineer', 'student', 'nurse'

  const UserProfile({required this.age, required this.profession});

  UserProfile copyWith({int? age, String? profession}) => UserProfile(
        age: age ?? this.age,
        profession: profession ?? this.profession,
      );
}
