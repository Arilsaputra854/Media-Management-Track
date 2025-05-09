import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_bloc.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_event.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_state.dart';
import 'package:media_management_track/auth/presentation/pages/register_page.dart';
import 'package:media_management_track/dashboard/presentation/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void _onLoginPressed(BuildContext context) {
      final email = emailController.text;
      final password = passwordController.text;

      context.read<AuthBloc>().add(
        LoginRequested(email: email, password: password),
      );
    }

    void _onRegisterPressed(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        builder: (context, state) {
          return Center(
            child: Container(
              width: 500,
              height: 300,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email"),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: "Password"),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        child: Text("Daftar"),
                        onTap: () => _onRegisterPressed(context),
                      ),
                      state is AuthLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () => _onLoginPressed(context),
                            child: Text("Login"),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Selamat Datang!, ${state.user.email}")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
    );
  }
}
