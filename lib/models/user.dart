class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? address;
  final String? gender;
  final String? token;
  final String? refreshToken;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.address,
    this.gender,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      gender: json['gender'],
      token: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}