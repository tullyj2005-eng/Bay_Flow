class Staff {
  final String id;
  final String name;
  final String email;
  final String role;       // "owner" or "tech"
  final String shopId;
  final String status;     // "available" or "busy"
  final String? assignedBayId;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.shopId,
    required this.status,
    this.assignedBayId,
  });

  factory Staff.fromMap(Map<String, dynamic> data, String id) {
    return Staff(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'tech',
      shopId: data['shopId'] ?? '',
      status: data['status'] ?? 'available',
      assignedBayId: data['assignedBayId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'shopId': shopId,
      'status': status,
      'assignedBayId': assignedBayId,
    };
  }
}