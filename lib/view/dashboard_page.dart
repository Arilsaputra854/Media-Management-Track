import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/view/borrow_media_page.dart';
import 'package:media_management_track/view/history_borrow_page.dart';
import 'package:media_management_track/view/media_page.dart';
import 'package:media_management_track/view/trainer_page.dart';
import 'package:media_management_track/viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget? _selectedBody;

  late DashboardViewmodel vm;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = context.read<DashboardViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await vm.init();

      if (auth.FirebaseAuth.instance.currentUser == null) {
        context.go('/login');
      } else {
        setState(() {
          if (vm.currentUser?.role == 'admin') {
            _selectedBody = TrainerPage();
          } else if (vm.currentUser?.role == 'trainer') {
            _selectedBody = BorrowMediaPage(); 
          }
        });
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
          appBar: AppBar(title: const Text('Dashboard')),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text(
                    'Selamat Datang, ${vm.currentUser?.name}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),

                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Kelola Trainer'),
                    onTap: () {
                      setState(() {
                        _selectedBody = TrainerPage();
                      });
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.perm_media),
                    title: const Text('Kelola Media'),
                    onTap: () {
                      setState(() {
                        _selectedBody = MediaPage();
                      });
                      Navigator.pop(context);
                    },
                  ),
                if (vm.currentUser?.role == "trainer")
                  ListTile(
                    leading: const Icon(Icons.perm_media),
                    title: const Text('Pinjam Media'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('History Peminjaman'),
                  onTap: () {
                    setState(() {
                      _selectedBody = HistoryBorrowPage();
                    });
                    Navigator.pop(context);
                  },
                ),
                if (vm.currentUser?.role == "admin")
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Permintaan'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('Sekolah'),
                  onTap: () {
                    context.go('/');
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
          body: _selectedBody,
        );
      },
    );
  }
}
