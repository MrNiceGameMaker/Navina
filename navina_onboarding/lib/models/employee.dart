class Employee {
  final String? id;
  final String email;
  final String fullName;
  final String role;

  const Employee({
    this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }
}
