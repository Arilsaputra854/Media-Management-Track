import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/view/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void _onLoginPressed(BuildContext context) {
      final email = emailController.text;
      final password = passwordController.text;
    }

    void _onRegisterPressed(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }

    return Scaffold(
      body: Center(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
