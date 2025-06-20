import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodel/borrow_media_viewmodel.dart';
import '../model/media.dart';
import '../model/school.dart';

class BorrowMediaPage extends StatefulWidget {
  const BorrowMediaPage({super.key});

  @override
  State<BorrowMediaPage> createState() => _BorrowMediaPageState();
}

class _BorrowMediaPageState extends State<BorrowMediaPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late BorrowMediaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = context.read<BorrowMediaViewModel>();
    vm.init();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      context.go('/login');
    } else {
      vm.checkHasActiveBorrow(userId);
    }
  }

  void _showBorrowDialog(BuildContext context, Media media, int maxCount) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pinjam ${media.name}'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Jumlah pcs'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final count = int.tryParse(controller.text) ?? 0;
                  if (count <= 0 || count > maxCount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jumlah tidak valid')),
                    );
                    return;
                  }

                  final vm = context.read<BorrowMediaViewModel>();
                  vm.setBorrowed(media, count);
                  Navigator.pop(context);
                },
                child: const Text('Tambah'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BorrowMediaViewModel>(
      builder: (context, vm, _) {
        if (vm.medias.isEmpty || vm.schools.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Column(
            children: [
              if (vm.hasActiveBorrow)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Kamu masih punya permintaan atau pinjaman yang belum selesai. Harap selesaikan dulu sebelum meminjam lagi.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<School>(
                  value: vm.selectedSchool,
                  items:
                      vm.schools.map((school) {
                        return DropdownMenuItem(
                          value: school,
                          child: Text(school.name),
                        );
                      }).toList(),
                  onChanged: vm.selectSchool,
                  decoration: const InputDecoration(labelText: 'Pilih Sekolah'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: vm.medias.length,
                  itemBuilder: (context, index) {
                    final media = vm.medias[index];
                    final available = media.items.length;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(media.name),
                        subtitle: Text('Tersedia: $available pcs'),
                        trailing:
                            available > 0
                                ? vm.hasActiveBorrow
                                    ? const Text(
                                      'Masih ada pinjaman aktif',
                                      style: TextStyle(color: Colors.orange),
                                    )
                                    : ElevatedButton(
  onPressed: () async {
    final allowed = await vm.checkHasActiveBorrow(userId!);
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masih ada pinjaman aktif!")),
      );
      return;
    }

    _showBorrowDialog(context, media, available);
  },
  child: const Text('Pinjam'),
)

                                : const Text(
                                  'Tidak Tersedia',
                                  style: TextStyle(color: Colors.grey),
                                ),
                      ),
                    );
                  },
                ),
              ),
              if (vm.borrowedItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Media yang Ingin Dipinjam:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.borrowedItems.length,
                      itemBuilder: (context, index) {
                        final entry = vm.borrowedItems.entries.elementAt(index);
                        final media = entry.key;
                        final count = entry.value;

                        return ListTile(
                          title: Text(media.name),
                          subtitle: Text('$count pcs'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              vm.removeBorrowed(media);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

              if (vm.borrowedItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        vm.hasActiveBorrow
                            ? null
                            : () async {
                              final userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("User belum login"),
                                  ),
                                );
                                return;
                              }

                              try {
                                await vm.submitBorrowRequests(userId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Permintaan berhasil dikirim!",
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Gagal mengirim: $e")),
                                );
                              }
                            },

                    icon: const Icon(Icons.check),
                    label: const Text('Konfirmasi Pinjam'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
