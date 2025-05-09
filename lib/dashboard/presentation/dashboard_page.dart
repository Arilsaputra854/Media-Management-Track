import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/auth/domain/entities/user.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_bloc.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_event.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_state.dart';
import 'package:media_management_track/auth/presentation/pages/login_page.dart';
import 'package:media_management_track/trainer_page/presentation/view/trainer_page.dart';

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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoginSuccess) {
          currentUser = state.user;
        } else if (state is AuthLogoutSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          });
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
                    'Selamat Datang, ${currentUser?.name}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
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
                ListTile(
                  leading: const Icon(Icons.perm_media),
                  title: const Text('Kelola Media'),
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
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                ),
              ],
            ),
          ),
          body: _selectedBody
        );
      },
    );
  }
}