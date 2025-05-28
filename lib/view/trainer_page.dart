import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:media_management_track/model/user.dart' show User;
import 'package:media_management_track/viewmodel/trainer_viewmodel.dart';
import 'package:provider/provider.dart';

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {

  late TrainerViewmodel vm;
  @override
  void initState() {
    vm = Provider.of<TrainerViewmodel>(context, listen: false);
    vm.fetchUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainerViewmodel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Kelola Trainer")),
          body: vm.users.isEmpty
              ? const Center(child: Text("Belum ada trainer terdaftar."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vm.users.length,
                  itemBuilder: (context, index) {
                    final user = vm.users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text(
                              user.institution,
                              style: const TextStyle(color: Colors.grey),
                            ),
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
}