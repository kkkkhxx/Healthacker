class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
    );
  }
}
