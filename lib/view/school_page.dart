import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/school.dart';
import 'package:media_management_track/viewmodel/school_viewmodel.dart';
import 'package:provider/provider.dart';

class SchoolPage extends StatefulWidget {
  const SchoolPage({super.key});

  @override
  State<SchoolPage> createState() => _SchoolPageState();
}

class _SchoolPageState extends State<SchoolPage> {
  late SchoolViewmodel vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = Provider.of<SchoolViewmodel>(context, listen: false);
    vm.init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolViewmodel>(
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addSchoolDialog(),
            child: Icon(Icons.add),
          ),
          body: Stack(
            children: [
              vm.schools.isEmpty
                  ? const Center(
                    child: Text("Belum ada sekolah yang terdaftar."),
                  )
                  : ListView.builder(
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
                            child: Text(
                              school.name.isNotEmpty
                                  ? school.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
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
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ],
                          ),

                          onTap: () {
                            _editSchoolDialog(school);
                          },
                        ),
                      );
                    },
                  ),
              if (vm.isLoading) Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  void _editSchoolDialog(School school) {
    final TextEditingController nameController = TextEditingController(
      text: school.name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  void _addSchoolDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }
}
