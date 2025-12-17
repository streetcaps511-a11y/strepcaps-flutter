// lib/models/user.dart

class User {
  final String email;
  final String name;
  final bool isAdmin;
  final String username;
  final String phone;
  final String department;
  final String city;
  final String address;
  final String docType;      // 👈 Nuevo
  final String docNumber;    // 👈 Nuevo

  User({
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.username = '',
    this.phone = '',
    this.department = '',
    this.city = '',
    this.address = '',
    this.docType = '',
    this.docNumber = '',
  });

  factory User.fromEmail(String email, {String? name, bool isAdmin = false}) {
    return User(
      email: email,
      name: name ?? email.split('@').first,
      isAdmin: isAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'username': username,
      'phone': phone,
      'department': department,
      'city': city,
      'address': address,
      'docType': docType,
      'docNumber': docNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      name: map['name'] as String,
      isAdmin: map['isAdmin'] as bool? ?? false,
      username: map['username'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      department: map['department'] as String? ?? '',
      city: map['city'] as String? ?? '',
      address: map['address'] as String? ?? '',
      docType: map['docType'] as String? ?? '',
      docNumber: map['docNumber'] as String? ?? '',
    );
  }
}