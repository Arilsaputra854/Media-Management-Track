import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/view/borrow_media_page.dart';
import 'package:media_management_track/view/borrow_request_page.dart';
import 'package:media_management_track/view/history_borrow_page.dart';
import 'package:media_management_track/view/media_page.dart';
import 'package:media_management_track/view/request_trainer_page.dart';
import 'package:media_management_track/view/return_media_page.dart';
import 'package:media_management_track/view/school_page.dart';
import 'package:media_management_track/view/school_trainer_page.dart';
import 'package:media_management_track/view/trainer_page.dart';
import 'package:media_management_track/viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardViewmodel vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = context.read<DashboardViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await vm.init();

      if (auth.FirebaseAuth.instance.currentUser == null) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewmodel>(
      builder: (context, vm, _) {
        if (vm.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(vm.pageTitle ?? 'Dashboard'),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Selamat Datang, ${vm.currentUser?.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Kelola Trainer'),
                    onTap: () {
                      vm.updatePage(const TrainerPage(), "Kelola Trainer", "trainer");
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.perm_media),
                    title: const Text('Kelola Media'),
                    onTap: () {
                      vm.updatePage(const MediaPage(), "Kelola Media", "media");
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "trainer")
                  ListTile(
                    leading: const Icon(Icons.perm_media),
                    title: const Text('Pinjam Media'),
                    onTap: () {
                      vm.updatePage(const BorrowMediaPage(), "Pinjam Media", "borrowMedia");
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('History Peminjaman'),
                  onTap: () {
                    vm.updatePage(
                      HistoryBorrowPage(userRole: vm.currentUser?.role ?? ''),
                      "Riwayat Peminjaman",
                      "history",
                    );
                    Navigator.pop(context);
                  },
                ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Permintaan Peminjaman Media'),
                    onTap: () {
                      vm.updatePage(const BorrowRequestPage(), "Permintaan Peminjaman", "borrowRequest");
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Permintaan Sebagai Trainer'),
                    onTap: () {
                      vm.updatePage(const RequestTrainerPage(), "Permintaan Trainer", "requestTrainer");
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Sekolah'),
                    onTap: () {
                      vm.updatePage(const SchoolPage(), "Kelola Sekolah", "school");
                      Navigator.pop(context);
                    },
                  ),
                  if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Institusi'),
                    onTap: () {
                      vm.updatePage(const SchoolTrainerPage(), "Kelola Institusi", "institution");
                      Navigator.pop(context);
                    },
                  ),
                  if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Pengembalian Sarana'),
                    onTap: () {
                      vm.updatePage(const ReturnMediaPage(), "Pengembalian Sarana", "return_sarana");
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    vm.logout();
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
          body: vm.selectedPage ?? const Center(child: Text("Tidak ada halaman yang dipilih")),
        );
      },
    );
  }
}
