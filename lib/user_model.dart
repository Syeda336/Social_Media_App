class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String bio;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.bio,
  });

  String get initials {
    if (fullName.trim().isEmpty) return "??";

    List<String> names = fullName.trim().split(" ");
    if (names.length > 1) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '', // ✅ ADD THIS
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
    );
  }
}