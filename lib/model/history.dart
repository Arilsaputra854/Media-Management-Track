import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot, Timestamp;

class History {
  final String id;
  final String userId;
  final String schoolId;
  final String mediaId;
  final int pcs;
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

  factory History.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return History(
    id: doc.id,
    userId: data['user_id'] ?? '',
    schoolId: data['school_id'] ?? '',
    mediaId: data['media_id'] ?? '',
    pcs: data['pcs'] is int ? data['pcs'] : int.tryParse(data['pcs'].toString()) ?? 0,
    borrowAt: (data['borrow_at'] as Timestamp).toDate(),
    returnAt: data['return_at'] != null
        ? (data['return_at'] as Timestamp).toDate()
        : null,
    status: data['status'] ?? 'borrow',
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
