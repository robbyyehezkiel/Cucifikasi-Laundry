class UserData {
  final String userId;
  final String email;
  final String name;
  final String address;
  final bool isAdmin;

  UserData({
    required this.userId,
    required this.email,
    required this.name,
    required this.address,
    required this.isAdmin,
  });

  UserData.fromFirestore(String userId, Map<String, dynamic> data)
      : userId = userId,
        email = data['email'] ?? '',
        name = data['name'] ?? '',
        address = data['address'] ?? '',
        isAdmin = data['isAdmin'] == 1;

  UserData.fromMap(Map<String, dynamic> map)
      : userId = map['userId'] ?? '',
        email = map['email'] ?? '',
        name = map['name'] ?? '',
        address = map['address'] ?? '',
        isAdmin = map['isAdmin'] == 1;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'address': address,
      'isAdmin': isAdmin,
      'lowercaseName': name.toLowerCase(),
    };
  }
}
