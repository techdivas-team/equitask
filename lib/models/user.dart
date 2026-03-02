class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? fullName;
  final String? role;
  final String? organizationId;
  final String? phone;
  final bool? isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.fullName,
    this.role,
    this.organizationId,
    this.phone,
    this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '').toString();
    final fallbackName = email.contains('@') ? email.split('@').first : 'User';

    return User(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? fallbackName).toString(),
      email: email,
      avatarUrl: json['avatarUrl']?.toString(),
      fullName: json['fullName']?.toString(),
      role: json['role']?.toString(),
      organizationId: json['organizationId']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (fullName != null) 'fullName': fullName,
      if (role != null) 'role': role,
      if (organizationId != null) 'organizationId': organizationId,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
