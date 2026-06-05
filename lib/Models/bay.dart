class Bay {
  final String id;
  final String bayName;
  final String type;
  final List<String> equipment;
  final String status;
  final String? assignedJobId;
  final String? assignedTechId;
  final String? assignedTechName;

  Bay({
    required this.id,
    required this.bayName,
    required this.type,
    required this.equipment,
    required this.status,
    this.assignedJobId,
    this.assignedTechId,
    this.assignedTechName,
  });

  factory Bay.fromMap(Map<String, dynamic> data, String id) {
    return Bay(
      id: id,
      bayName: data['bayName'] ?? '',
      type: data['type'] ?? '',
      equipment: List<String>.from(data['equipment'] ?? []),
      status: data['status'] ?? 'available',
      assignedJobId: data['assignedJobId'],
      assignedTechId: data['assignedTechId'],
      assignedTechName: data['assignedTechName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bayName': bayName,
      'type': type,
      'equipment': equipment,
      'status': status,
      'assignedJobId': assignedJobId,
      'assignedTechId': assignedTechId,
      'assignedTechName': assignedTechName,
    };
  }
}