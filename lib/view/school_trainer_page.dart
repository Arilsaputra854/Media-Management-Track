import 'package:flutter/material.dart';
import 'package:media_management_track/model/school.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/viewmodel/school_trainer_viewmodel.dart';
import 'package:provider/provider.dart';

class SchoolTrainerPage extends StatefulWidget {
  const SchoolTrainerPage({super.key});

  @override
  State<SchoolTrainerPage> createState() => _SchoolTrainerPageState();
}

class _SchoolTrainerPageState extends State<SchoolTrainerPage> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<SchoolTrainerViewmodel>(context, listen: false);
    _initFuture = vm.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institusi Trainer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                final vm = Provider.of<SchoolTrainerViewmodel>(context, listen: false);
                _initFuture = vm.init();
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchoolDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          final vm = Provider.of<SchoolTrainerViewmodel>(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingWidget("Memuat data sekolah...");
          }

          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
          }

          if (vm.schools.isEmpty) {
            return const Center(child: Text("Belum ada sekolah yang terdaftar."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: vm.schools.length,
            itemBuilder: (context, index) {
              final school = vm.schools[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    child: Text(
                      school.name.isNotEmpty ? school.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    school.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editSchoolDialog(school);
                      } else if (value == 'delete') {
                        vm.removeSchool(school);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                  onTap: () => _editSchoolDialog(school),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editSchoolDialog(School school) {
    final nameController = TextEditingController(text: school.name);
    final vm = Provider.of<SchoolTrainerViewmodel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Sekolah'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Sekolah',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                vm.updateSchool(School(newName, school.id));
                Navigator.pop(context);
              }
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _addSchoolDialog() {
    final nameController = TextEditingController();
    final vm = Provider.of<SchoolTrainerViewmodel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Sekolah'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Sekolah',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                vm.addSchool(newName);
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
