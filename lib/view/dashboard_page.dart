import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/view/trainer_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? currentUser;
  Widget _selectedBody = TrainerPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Selamat Datang, ${currentUser?.name}',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            if (currentUser?.role == "admin")
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
            if (currentUser?.role == "admin")
              ListTile(
                leading: const Icon(Icons.perm_media),
                title: const Text('Kelola Media'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            if (currentUser?.role == "trainer")
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
                Navigator.pop(context);
              },
            ),
            if (currentUser?.role == "admin")
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Permintaan'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _selectedBody,
    );
  }
}
