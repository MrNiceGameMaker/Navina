class EmployeeModel {
  final String id;
  final String name;
  final String role;
  final String status;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
