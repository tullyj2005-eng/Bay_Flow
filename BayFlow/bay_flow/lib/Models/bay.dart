class Bay {
  final String id;
  final String bayName;
  final String type;
  final List<String> equipment;
  final String status;

  Bay({
    required this.id,
    required this.bayName,
    required this.type,
    required this.equipment,
    required this.status,
  });

  factory Bay.fromMap(Map<String, dynamic> data, String id) {
    return Bay(
      id: id,
      bayName: data['bayName'] ?? '',
      type: data['type'] ?? '',
      equipment: List<String>.from(data['equipment'] ?? []),
      status: data['status'] ?? '',
    );
  }
}