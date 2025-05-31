import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart';

class TrainerDetailPage extends StatefulWidget {
  final User user;
  const TrainerDetailPage({super.key, required this.user});

  @override
  State<TrainerDetailPage> createState() => _TrainerDetailPageState();
}

class _TrainerDetailPageState extends State<TrainerDetailPage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/dashboard');
          },
        ),
        title: const Text("Detail Trainer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informasi Trainer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Nama"),
                  subtitle: Text(user.name),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Peran"),
                  subtitle: Text(user.role),
                ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Institusi"),
                  subtitle: Text(user.institution),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
