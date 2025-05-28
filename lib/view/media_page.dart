import 'package:flutter/material.dart';
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
    vm.fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaViewmodel>(
      builder: (context, vm, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(onPressed: (){
            showDialogAddMedia(context);
          },child: Icon(Icons.add),),
          appBar: AppBar(title: const Text("Kelola Media Pembelajaran")),
          body: vm.media.isEmpty
              ? const Center(child: Text("Belum ada trainer terdaftar."))
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
                          child: Image.network(vm.media[index].imageUrl),
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
                            Text("Total : ${media.countAll}"),
                            Text("Tersedia : ${media.countAll - media.count}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
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
  final TextEditingController countController = TextEditingController();
  final TextEditingController countAllController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  MediaStatus selectedStatus = MediaStatus.ready;

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
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Count (Tersedia)"),
              ),
              TextField(
                controller: countAllController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Count All (Total)"),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: "Image URL"),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nama Media"),
              ),
              DropdownButtonFormField<MediaStatus>(
                value: selectedStatus,
                items: MediaStatus.values.map((MediaStatus status) {
                  return DropdownMenuItem<MediaStatus>(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedStatus = value;
                  }
                },
                decoration: InputDecoration(labelText: "Status"),
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
            onPressed: () {
              // Validasi sederhana
              if (countController.text.isEmpty ||
                  countAllController.text.isEmpty ||
                  imageUrlController.text.isEmpty ||
                  nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Semua field wajib diisi.")),
                );
                return;
              }

              // Lakukan proses simpan ke database di sini
              print("Media Ditambahkan:");
              print("Count: ${countController.text}");
              print("Count All: ${countAllController.text}");
              print("Image URL: ${imageUrlController.text}");
              print("Name: ${nameController.text}");
              print("Status: ${selectedStatus.name}");

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}