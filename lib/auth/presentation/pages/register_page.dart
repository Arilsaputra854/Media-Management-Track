import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_bloc.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_event.dart';
import 'package:media_management_track/auth/presentation/bloc/auth_state.dart';

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

      context.read<AuthBloc>().add(RegisterRequested(email: email, password: password, name: name));
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
                      state is AuthLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () => _onRegisterPressed(context),
                            child: Text("Register"),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        listener: (context, state) {
           if(state is AuthRegisterSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Registrasi telah berhasil, Silakan login."))              
            );
            Navigator.pop(context);
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
