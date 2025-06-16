
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowRequest {
  final String id;
  final String mediaId;
  final String schoolId;
  final int pcs;
  final String mediaName;
  final DateTime requestAt;
  final DateTime? acceptAt;
  final String status;
  final String userId;

  BorrowRequest({
    required this.id,
    required this.schoolId,
    required this.mediaId,
    required this.mediaName,
    required this.pcs,
    required this.requestAt,
    this.acceptAt,
    required this.status,
    required this.userId,
  });

  factory BorrowRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BorrowRequest(
      id: doc.id,
      mediaId: data['media_id'] ?? '',
      mediaName: data['media_name'] ?? '',
      schoolId: data['school_id'] ?? '',
      pcs: data['pcs'] ?? '',
      requestAt: (data['request_at'] as Timestamp).toDate(),
      acceptAt: data['accept_at'] != null ?(data['accept_at'] as Timestamp).toDate() : null,
      status: data['status'] ?? '',
      userId: data['user_id'] ?? '',
    );
  }
}