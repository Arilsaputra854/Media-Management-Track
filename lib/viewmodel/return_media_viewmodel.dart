import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnMediaViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> returnMedia(String qrText) async {
    // Format QR: "mediaId - mediaName - itemId"
    final parts = qrText.split(' - ');
    if (parts.length != 3) throw 'Format QR tidak valid';

    final mediaId = parts[0];
    final itemId = parts[2];

    // 1. Update data item di koleksi `media`
    final mediaRef = _firestore.collection('media_kit').doc(mediaId);
    final mediaSnap = await mediaRef.get();

    if (!mediaSnap.exists) throw 'Media tidak ditemukan';

    final mediaData = mediaSnap.data()!;
    final items = List<Map<String, dynamic>>.from(mediaData['items']);

    final index = items.indexWhere((e) => e['id'] == itemId);
    if (index == -1) throw 'Item tidak ditemukan';

    final borrowedBy = items[index]['borrowed_by'];
    if (borrowedBy == null) throw 'Item tidak sedang dipinjam';

    // Update status item
    items[index]['status'] = 'ready';
    items[index]['borrowed_by'] = null;
    items[index]['borrowed_at'] = null;

    await mediaRef.update({'items': items});

    // 2. Update dokumen `history`
    final historyQuery = await _firestore
        .collection('history')
        .where('media_id', isEqualTo: mediaId)
        .where('user_id', isEqualTo: borrowedBy)
        .where('status', isEqualTo: 'borrow')
        .limit(1)
        .get();

    if (historyQuery.docs.isEmpty) throw 'Riwayat tidak ditemukan';

    final historyDocRef = historyQuery.docs.first.reference;
    await historyDocRef.update({
      'status': 'return',
      'return_at': FieldValue.serverTimestamp(),
    });
  }
}
