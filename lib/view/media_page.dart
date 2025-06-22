import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/media.dart';
import 'package:media_management_track/viewmodel/media_viewmodel.dart';
import 'package:media_management_track/viewmodel/trainer_viewmodel.dart';
import 'package:provider/provider.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late MediaViewmodel vm;
  @override
  void initState() {
    vm = Provider.of<MediaViewmodel>(context, listen: false);
    vm.fetchMedia();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

  
    return Consumer<MediaViewmodel>(
      builder: (context, vm, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialogAddMedia(context);
            },
            child: Icon(Icons.add),
          ),
          body:
              vm.media.isEmpty
                  ? const Center(child: Text("Belum ada Media."))
                  : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.media.length,
                    itemBuilder: (context, index) {
                      final media = vm.media[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              media.name.isNotEmpty
                                  ? media.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          title: Text(
                            media.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total : ${media.items.length}"),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                          onTap: () {
                            context.go('/media/${media.id}');
                          },
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }

  void showDialogAddMedia(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Media"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nama Media"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () async {
                // Validasi sederhana
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Semua field wajib diisi.")),
                  );
                  return;
                }

                // Lakukan proses simpan ke database di sini
                bool isSuccess = await vm.addMedia(
                  Media(
                    name: nameController.text,
                    createdAt: DateTime.now(),
                    items: [],
                  ),
                );

                if (isSuccess) {
                  Fluttertoast.showToast(
                    msg: "Berhasil menambahkan media baru.",
                  );
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(
                    msg: "Tidak dapat membuat media baru, coba lagi nanti.",
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
