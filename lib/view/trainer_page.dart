import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart' show User;
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/viewmodel/trainer_viewmodel.dart';
import 'package:provider/provider.dart';

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});


  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TrainerViewmodel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Trainer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // trigger rebuild with setState using StatefulWidget if needed
            },
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: vm.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  LoadingWidget("Memuat data trainer");
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada trainer terdaftar."));
          }

          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
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
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    context.go('/trainer', extra: user);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}