class Job {
  final String id;
  final String customerName;
  final String vehicle;
  final String jobType;
  final int priority;
  final String shopId;
  final String status;
  final String notes;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.jobType,
    required this.priority,
    required this.shopId,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> data, String id) {
    return Job(
      id: id,
      customerName: data['customerName'] ?? '',
      vehicle: data['vehicle'] ?? '',
      jobType: data['jobType'] ?? '',
      priority: data['priority'] ?? 0,
      shopId: data['shopId'] ?? '',
      status: data['status'] ?? 'queued',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'vehicle': vehicle,
      'jobType': jobType,
      'notes': notes,
      'priority': priority,
      'shopId': shopId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}