import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaStatus { ready, borrow }

MediaStatus mediaStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'ready':
      return MediaStatus.ready;
    case 'borrow':
      return MediaStatus.borrow;
    default:
      throw Exception('Unknown MediaStatus: $status');
  }
}

String mediaStatusToString(MediaStatus status) {
  switch (status) {
    case MediaStatus.ready:
      return 'ready';
    case MediaStatus.borrow:
      return 'borrow';
  }
}

class Media {
  final String name;
  final int count;
  final int countAll;
  final DateTime createdAt;
  final MediaStatus status;
  final String imageUrl;
  final Map<String, dynamic> items;

  Media({
    required this.name,
    required this.count,
    required this.countAll,
    required this.createdAt,
    required this.status,
    required this.imageUrl,
    this.items = const {}
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      countAll: json['count_all'] ?? 0,
      imageUrl: json['image_url'],
      createdAt: (json['create_at'] as Timestamp).toDate(),
      status: mediaStatusFromString(json['status'] ?? 'ready'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'count_all': countAll,
      'image_url' : imageUrl,
      'create_at': Timestamp.fromDate(createdAt),
      'status': mediaStatusToString(status),
    };
  }
}


class MediaItem {
  final String id;
  final MediaStatus status;
  final String? borrowedBy;
  final DateTime? borrowedAt;
  final DateTime? returnedAt;

  MediaItem({
    required this.id,
    required this.status,
    this.borrowedBy,
    this.borrowedAt,
    this.returnedAt,
  });

  factory MediaItem.fromJson(String id, Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      status: mediaStatusFromString(json['status']),
      borrowedBy: json['borrowed_by'],
      borrowedAt: (json['borrowed_at'] as Timestamp?)?.toDate(),
      returnedAt: (json['returned_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': mediaStatusToString(status),
      'borrowed_by': borrowedBy,
      'borrowed_at': borrowedAt != null ? Timestamp.fromDate(borrowedAt!) : null,
      'returned_at': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
    };
  }
}
