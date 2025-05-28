import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/model/user.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/view/widget/toast_widget.dart';
import 'package:media_management_track/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late LoginViewmodel vm;

  @override
  void didChangeDependencies() {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        context.go('/dashboard');
      }
    });

    vm = context.watch<LoginViewmodel>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                        onTap: () {
                          context.go("/register");
                        },
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool isSuccess = await vm.login(
                            emailController.text,
                            passwordController.text,
                          );

                          if (isSuccess) {
                            context.go('/dashboard');
                          } else {
                            if (vm.errorMsg != null) {
                              showToast(context, vm.errorMsg!);
                            }
                          }
                        },
                        child: Text("Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (vm.loading) LoadingWidget("Mohon Tunggu"),
      ],
    );
  }
}
