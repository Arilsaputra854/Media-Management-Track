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
  final String? id; 
  final String name;
  final DateTime createdAt;
  final List<MediaItem> items;

  Media({this.id, 
    required this.name,
    required this.createdAt,
    required this.items,
  });

  factory Media.fromJson(Map<String, dynamic> json,String documentId) {
    final List<dynamic> itemsJson = json['items'] ?? [];

    return Media(
      id: documentId, 
      name: json['name'] ?? '',
      createdAt: (json['create_at'] as Timestamp).toDate(),
      items: itemsJson.map((itemJson) => MediaItem.fromJson(itemJson)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'create_at': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
      // Convert list of MediaItem objects to a list of maps
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

}


class MediaItem {
  final String id;
  final DateTime? borrowedAt;
  final String? borrowedBy;
  final DateTime? returnedAt;
  final MediaStatus status;

  MediaItem({
    required this.id,
    this.borrowedAt,
    this.borrowedBy,
    this.returnedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'borrowed_at': borrowedAt != null ? Timestamp.fromDate(borrowedAt!) : null,
      'borrowed_by': borrowedBy,
      'returned_at': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
      // Use the helper function to convert the enum to a string
      'status': mediaStatusToString(status),
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      borrowedAt: (json['borrowed_at'] as Timestamp?)?.toDate(),
      borrowedBy: json['borrowed_by'],
      returnedAt: (json['returned_at'] as Timestamp?)?.toDate(),
      status: mediaStatusFromString(json['status']),
    );
  }
}
