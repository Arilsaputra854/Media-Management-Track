import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    final vm = context.read<BorrowMediaViewModel>();
    vm.init();
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
                  if (count <= 0 || count > media.count) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jumlah tidak valid')),
                    );
                    return;
                  }
                  context.read<BorrowMediaViewModel>().setBorrowed(
                    media,
                    count,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Konfirmasi'),
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
          appBar: AppBar(title: const Text('Pinjam Media')),
          body: Column(
            children: [
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
                    final available = media.count;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Image.network(
                          media.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(media.name),
                        subtitle: Text('Tersedia: $available pcs'),
                        trailing:
                            available > 0
                                ? ElevatedButton(
                                  onPressed:
                                      () => _showBorrowDialog(
                                        context,
                                        media,
                                        available,
                                      ),
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
                    onPressed: () {
                      // lanjut ke konfirmasi halaman atau simpan ke Firestore
                      print("Borrowing from: ${vm.selectedSchool?.name}");
                      vm.borrowedItems.forEach((media, count) {
                        print("📦 ${media.name}: $count pcs");
                      });
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
