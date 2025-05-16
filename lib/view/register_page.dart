import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void _onRegisterPressed(BuildContext context) {
      String email = emailController.text;
      String name = nameController.text;
      String password = passwordController.text;

    }

    return Scaffold(
      body:  Center(
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
                        controller: nameController,
                        decoration: InputDecoration(labelText: "Nama"),
                      ),
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
                      ElevatedButton(
                            onPressed: () => _onRegisterPressed(context),
                            child: Text("Register"),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          )
    );
  }
}
