import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:media_management_track/model/media.dart';
import 'package:media_management_track/viewmodel/media_detail_viewmodel.dart';
import 'dart:html' as html;

import 'package:qr_flutter/qr_flutter.dart';

class MediaDetailPage extends StatefulWidget {
  final String documentId;
  const MediaDetailPage({super.key, required this.documentId});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  final DetailMediaViewModel _viewModel = DetailMediaViewModel();
  final TextEditingController _itemIdController = TextEditingController();
  GlobalKey repaintBoundaryKey = GlobalKey();
  bool isLoading = false;

  // Fungsi untuk menampilkan dialog tambah item
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Item Baru'),
          content: TextField(
            controller: _itemIdController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'ID Item Baru',
              hintText: 'Contoh: A001, B002, dll.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _itemIdController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Tambah'),
              onPressed: () async {
                if (_itemIdController.text.isNotEmpty) {
                  final success = await _viewModel.addNewItem(
                    documentId: widget.documentId,
                    newItemId: _itemIdController.text,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _itemIdController.clear();
                    Navigator.of(dialogContext).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _viewModel.errorMessage ?? 'Terjadi kesalahan.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/dashboard');
          },
        ),
        title: const Text("Detail Media"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('media_kit')
                .doc(widget.documentId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Media tidak ditemukan."));
          }

          // Parsing data dari snapshot ke objek Media
          final media = Media.fromJson(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Header (Gambar dan Nama)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        media.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Dibuat pada: ${DateFormat.yMMMd().format(media.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bagian Daftar Item
                Text(
                  "Daftar Media (${media.items.length})",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                if (media.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text('Belum ada item untuk media ini.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: media.items.length,
                    itemBuilder: (context, index) {
                      final item = media.items[index];
                      final bool isReady = item.status == MediaStatus.ready;

                      final GlobalKey itemQrKey = GlobalKey();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isReady ? Colors.green : Colors.orange,
                            child: Icon(
                              isReady ? Icons.check : Icons.person_pin_circle,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'ID: ${item.id}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: isReady
    ? const Text('Tersedia')
    : FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(item.borrowedBy)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Memuat...');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Dipinjam oleh: (tidak diketahui)');
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'Tanpa Nama';
          return Text('Dipinjam oleh: $userName');
        },
      ),

                          trailing: IconButton(
                            icon: const Icon(Icons.qr_code_2),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text('Buat QR Code Media'),
                                      content: SizedBox(
                                        height: 50,
                                        child: QrCodeGenerator(
                                        qrData:
                                            '${media.id} - ${media.name} - ${item.id}',
                                      ),
                                      )
                                    ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Item"),
      ),
    );
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    super.dispose();
  }
}

class QrCodeGenerator extends StatefulWidget {
  final String qrData; // Data teks untuk QR code

  const QrCodeGenerator({Key? key, required this.qrData}) : super(key: key);

  @override
  _QrCodeGeneratorState createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  bool isLoading = false;

  Future<void> _generateAndDownloadQr() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Membuat QrPainter dengan data QR
      final qrPainter = QrPainter(
        data: widget.qrData,
        version: QrVersions.auto,
        gapless: false,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      );

      // Mengubah QR code menjadi gambar (ui.Image)
      final ui.Image qrImage = await qrPainter.toImage(300);

      // Mengubah ui.Image menjadi byte data PNG
      final ByteData? byteData = await qrImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null)
        throw Exception("Gagal mengonversi QR code ke byte data");

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Membuat URL dari byte data untuk download (khusus Flutter Web)
      final blob = html.Blob([pngBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Membuat elemen anchor untuk download
      final anchor =
          html.AnchorElement()
            ..href = url
            ..download = '${widget.qrData}.png'
            ..style.display = 'none';

      // Menambahkan anchor ke DOM dan klik otomatis untuk download
      html.document.body!.append(anchor);
      anchor.click();

      // Membersihkan elemen dan URL object
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Tangani error dan tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal generate/download QR code: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code),
          label: const Text('Generate & Download QR'),
          onPressed: isLoading ? null : _generateAndDownloadQr,
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    ),);
  }
}
