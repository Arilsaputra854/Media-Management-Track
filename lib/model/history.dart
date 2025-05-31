import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class History {
  final String userId;
  final String schoolId;
  final DateTime borrowAt;
  final DateTime? returnAt;
  final String status; 

  History({
    required this.userId,
    required this.schoolId,
    required this.borrowAt,
    this.returnAt,
    required this.status,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      userId: json['user_id'] ?? '',
      schoolId: json['school_id'] ?? '',
      borrowAt: (json['borrow_at'] as Timestamp).toDate(),
      returnAt: json['return_at'] != null ? (json['return_at'] as Timestamp).toDate() : null,
      status: json['status'] ?? 'borrow',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'school_id': schoolId,
      'borrow_at': borrowAt,
      'return_at': returnAt,
      'status': status,
    };
  }
}
