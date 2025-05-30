import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_management_track/view/widget/loading_widget.dart';
import 'package:media_management_track/view/widget/toast_widget.dart';
import 'package:media_management_track/viewmodel/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    RegisterViewmodel vm = context.watch<RegisterViewmodel>();
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    String? currentInstitution;

    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Container(
              width: 500,
              height: 350,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama wajib diisi';
                            }
                          },
                          controller: nameController,
                          decoration: InputDecoration(labelText: "Nama"),
                        ),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email wajib diisi';
                            }

                            // Validasi dengan regex
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Format email tidak valid';
                            }

                            return null; // valid
                          },

                          decoration: InputDecoration(labelText: "Email"),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                          },
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(labelText: "Password"),
                          obscureText: true,
                        ),
                        FutureBuilder(
                          future: vm.getInstitutions(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            return DropdownButtonFormField(
                              items:
                                  snapshot.data!.map((institution) {
                                    return DropdownMenuItem(
                                      child: Text(institution),
                                      value: institution,
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                currentInstitution = value;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (currentInstitution == null) {
                              showToast(
                                context,
                                "Silakan pilih institusi asal kamu.",
                              );
                            }
                            if (_formKey.currentState!.validate() &&
                                currentInstitution != null) {
                              bool isSuccess = await vm.register(
                                email: emailController.text,
                                password: passwordController.text,
                                name: nameController.text,
                                institution: currentInstitution!,
                              );
                              if (isSuccess) {
                                showToast(context, "Berhasil membuat Akun.");
                                context.go('/login');
                              } else {
                                if (vm.errorMsg != null) {
                                  showToast(context, vm.errorMsg!);
                                }
                              }
                            }
                          },
                          child: Text("Register"),
                        ),
                      ],
                    ),
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
