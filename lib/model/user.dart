class User {
  String id;
  String name;
  String email;
  String role;
  String institution;
  String status;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.institution,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? id}) {
    return User(
      id: id ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      institution: json['institution'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'institution': institution,
      'status': status,
    };
  }
}
