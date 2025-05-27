class User {
  String name;
  String email;
  String role;
  String institution;

  User({
    required this.email,
    required this.name,
    required this.role,
    required this.institution,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      institution: json['institution'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'institution': institution,
    };
  }
}
