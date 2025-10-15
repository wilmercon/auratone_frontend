class User {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? secondLastName;
  final String ci;
  final String email;
  final DateTime createdAt;

  String get fullName {
    String name = firstName;
    if (middleName != null) name += ' $middleName';
    name += ' $lastName';
    if (secondLastName != null) name += ' $secondLastName';
    return name;
  }

  User({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.secondLastName,
    required this.ci,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String,
      secondLastName: json['second_last_name'] as String?,
      ci: json['ci'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'second_last_name': secondLastName,
      'ci': ci,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
