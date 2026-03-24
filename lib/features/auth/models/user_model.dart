class UserModel {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String username;
  final String email;
  final String mobile;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.mobile,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      mobile: json['mobile'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "mobile": mobile,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}
