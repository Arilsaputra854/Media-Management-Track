import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class History {
  final String id;
  final String userId;
  final String schoolId;
  final String mediaId; // ✅ DITAMBAHKAN
  final String pcs;
  final DateTime borrowAt;
  final DateTime? returnAt;
  final String status;

  History({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.mediaId, // ✅ DITAMBAHKAN
    required this.borrowAt,
    required this.pcs,
    this.returnAt,
    required this.status,
  });

  factory History.fromJson(Map<String, dynamic> json, String id) {
    return History(
      id: id,
      userId: json['user_id'] ?? '',
      schoolId: json['school_id'] ?? '',
      mediaId: json['media_id'] ?? '', // ✅ DITAMBAHKAN
      pcs: json['pcs'] ?? '',
      borrowAt: (json['borrow_at'] as Timestamp).toDate(),
      returnAt: json['return_at'] != null
          ? (json['return_at'] as Timestamp).toDate()
          : null,
      status: json['status'] ?? 'borrow',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'school_id': schoolId,
      'media_id': mediaId, // ✅ DITAMBAHKAN
      'borrow_at': borrowAt,
      'return_at': returnAt,
      'pcs': pcs,
      'status': status,
    };
  }
}
