import 'package:flutter/material.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/viewmodel/request_trainer_viewmodel.dart';
import 'package:provider/provider.dart';

class RequestTrainerPage extends StatefulWidget {
  const RequestTrainerPage({super.key});

  @override
  State<RequestTrainerPage> createState() => _RequestTrainerPageState();
}

class _RequestTrainerPageState extends State<RequestTrainerPage> {
  late RequestTrainerViewmodel vm;
  @override
  void initState() {
    vm = Provider.of<RequestTrainerViewmodel>(context, listen: false);
    vm.fetchRequestedUsers();
    super.initState();
  }

  @override
Widget build(BuildContext context) {
  return Consumer<RequestTrainerViewmodel>(
    builder: (context, vm, _) {
      return Scaffold(
        body: Stack(
          children: [
            vm.requestedUsers.isEmpty
                ? const Center(child: Text("Belum ada permohonan."))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.requestedUsers.length,
                    itemBuilder: (context, index) {
                      final user = vm.requestedUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      vm.declineUser(user.id);
                                    },
                                    child: const Text(
                                      "Tolak",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      vm.acceptUser(user.id);
                                    },
                                    child: const Text("Terima"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            if (vm.isLoading)  LoadingWidget("Memuat data trainer"),
          ],
        ),
      );
    },
  );
}

}
